using Agents
using Random, LinearAlgebra

@agent struct Particle(ContinuousAgent{2,Float64})
    speed::Float64
    whimsy::Float64
    collisions::Int64
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
        randomwalk!(particle, model, 0.1, polar = Uniform(0.99*π,1.01*π))
    end
    new_collisions = count_neighbors
    particle.collisions += new_collisions
    # normal movement
    randomwalk!(particle, model, particle.speed, polar = Uniform(-particle.whimsy*π/180,particle.whimsy*π/180))

end

function initialize_model(;
    n_particles = 50,
    speed = 1,
    whimsy = 45,
    collisions = 0,
    extent = (100, 100),
    seed = 42,
)
    space2d = ContinuousSpace(extent; spacing = 1/1.5, periodic = true)
    rng = Random.MersenneTwister(seed)

    model = StandardABM(Particle, space2d; rng, agent_step!, 
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
            collisions,
        )
    end
    return model
end


model = initialize_model()

using CairoMakie

# this part does not work (i.e abmplot throws error, see issue #1045)
const particle_polygon = Makie.Polygon(Point2f[(-1, -1), (2, 0), (-1, 1)])
function particle_marker(b::Particle)
    φ = atan(b.vel[2], b.vel[1]) #+ π/2 + π
    rotate_polygon(particle_polygon, φ)
end

abmvideo(
    "flocking.mp4", model;
    #agent_marker = :diamond,
    framerate = 10, frames = 500,
    title = "Flocking"
)


adata = [(:collisions, sum)]
adf, mdf = run!(model, 100; adata)


using GLMakie # using a different plotting backend that enables interactive plots

fig, abmobs = abmexploration(
    model; 
    adata
)
fig
