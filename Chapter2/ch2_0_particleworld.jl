using Agents
using Random, LinearAlgebra

@agent struct Particle(ContinuousAgent{2,Float64})
    speed::Float64
    whimsy::Float64
    #collisions::Int64
end

function agent_step!(particle, model)
    # reset neighbor count
    count_neighbors = 0
    # count nearby neighbors
    for neighbor in nearby_agents(particle, model, 2)
        count_neighbors += 1
    end
    # if any particles nearby, make a u-turn
    if count_neighbors > 0
        randomwalk!(particle, model, 0.2, polar = Uniform(0.99*π,1.01*π))
    end
    new_collisions = count_neighbors
    #particle.collisions += new_collisions this would be the way to track collisions at agent level
    model.total_collisions += new_collisions # instead we can track model-level collisions (Agents developers advise against it https://tinyurl.com/f384tpub)
    # normal movement
    randomwalk!(particle, model, particle.speed, polar = Uniform(-particle.whimsy*π/180,particle.whimsy*π/180))

end

function initialize_model(;
    n_particles = 50,
    speed = 1,
    whimsy = 45,
    #collisions = 0,
    total_collisions = 0,
    extent = (100, 100),
    seed = 123,
)
    space2d = ContinuousSpace(extent; spacing = 1/1.5, periodic = true)
    properties = Dict(:total_collisions => 0)
    rng = Random.MersenneTwister(seed)

    model = StandardABM(Particle, space2d; rng, agent_step!, properties,
                        container = Vector, # agents are not removed, so we use this
                        scheduler = Schedulers.Randomly())
    for _ in 1:n_particles
        # I still don't understand this
        vel = rand(abmrng(model), SVector{2}) * 2 .- 1
        add_agent!(
            model,
            vel,
            speed,
            whimsy,
            #collisions,
        )
    end
    return model
end


model = initialize_model()

using CairoMakie

# creating a custom marker shape
const particle_polygon = Makie.Polygon(Point2f[(-1, -1), (2, 0), (-1, 1)])
function particle_marker(b::Particle)
    φ = atan(b.vel[2], b.vel[1]) #+ π/2 + π
    rotate_polygon(particle_polygon, φ)
end

abmvideo(
    "particle_world.mp4", model;
    agent_marker = particle_marker,
    agent_size = 5,
    framerate = 10, frames = 500,
    title = "Particle World"
)

#adata = [(:collisions, sum)]
mdata = [:total_collisions]
#adf, mdf = run!(model, 100; adata)
mdf = run!(model, 100; mdata)

using GLMakie # using a different plotting backend that enables interactive plots

fig, abmobs = abmexploration(
    model; 
    agent_marker = particle_marker,
    adata
)
fig
