using Agents # bring package into scope


@agent struct SchellingAgent(GridAgent{2})
    happy::Bool # whether the agent is happy in its position
    group::Int # The group of the agent, determines mood as it interacts with neighbors
end


function schelling_step!(agent, model)
    # Here we access a model-level property `min_to_be_happy`.
    # This will have an assigned value once we create the model.
    threshold = model.similarity_threshold
    count_neighbors = 0
    count_neighbors_similar = 0
    # For each neighbor, get group and compare to current agent's group
    # and increment `count_neighbors_same_group` as appropriately.
    # Here `nearby_agents` (with default arguments) will provide an iterator
    # over the nearby agents one grid cell away, which are at most 8.
    for neighbor in nearby_agents(agent, model, 1)
        count_neighbors += 1
        if agent.group == neighbor.group
            count_neighbors_similar += 1
        end
    end
    # After counting the neighbors, decide whether or not to move the agent.
    # If count_neighbors_same_group is at least the min_to_be_happy, set the
    # mood to true. Otherwise, move the agent to a random position, and set
    # mood to false.
    if count_neighbors_similar / count_neighbors ≥ threshold
        agent.happy = true
    else
        agent.happy = false
        move_agent_single!(agent, model)
    end
    return
end

using Random: Xoshiro # access the RNG object

function initialize(; density = 0.9, gridsize = (51, 51), similarity_threshold = 0.7, seed = 125)
    space = GridSpaceSingle(gridsize; periodic = false, metric = :chebyshev)
    properties = Dict(
        :similarity_threshold => similarity_threshold,
        :density => density,             
    )
    rng = Xoshiro(1234)
    model = StandardABM(
        SchellingAgent, space;
        agent_step! = schelling_step!, properties, rng,
        container = Vector, # agents are not removed, so we use this
        scheduler = Schedulers.Randomly() # all agents are activated once at random
    )
    # populate the model with agents, adding equal amount of the two types of agents
    # at random positions in the model. At the start all agents are unhappy.
    total_agents = round(density*51*51)
    for n in 1:total_agents
        add_agent_single!(model; happy = false, group = n < total_agents / 2 ? 1 : 2)
    end
    return model
end

schelling = initialize()

params = Dict(
    :similarity_threshold => 0.2:0.1:0.8,
    :density => 0.2:0.1:0.8,
)

using Statistics: mean
adata = [(:happy, mean)]
alabels = ["avg_happiness"]

using GLMakie # using a different plotting backend that enables interactive plots

groupcolor(a) = a.group == 1 ? (:darkred , 0.7) : (:darkblue , 0.6)
groupmarker(a) = a.group == 1 ? :circle : :rect

fig, abmobs = abmexploration(
    schelling; 
    #add_controls = true,
    params,
    agent_color = groupcolor, agent_marker = groupmarker, agent_size = 10,
    adata, alabels
)
fig






using CairoMakie # choosing a plotting backend

groupcolor(a) = a.group == 1 ? (:darkred , 0.7) : (:darkblue , 0.6)
groupmarker(a) = a.group == 1 ? :circle : :rect

figure, _ = abmplot(schelling; agent_color = groupcolor, agent_marker = groupmarker, agent_size = 10)
figure # returning the figure displays it


schelling = initialize(; density = 0.5)
abmvideo(
    "schelling.mp4", schelling;
    agent_color = groupcolor, 
    agent_marker = groupmarker, 
    agent_size = 10,
    framerate = 6, frames = 500,
    title = "Schelling's segregation model"
)