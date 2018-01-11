is_run_file(filename) = ismatch(r"run.+\.csv", filename)
is_walk_file(filename) = ismatch(r"walk.+\.csv", filename)

function load_file(filename)
    local A = readcsv(filename)
    # x,y,z
    return A[:, 1:3]
end

const WALK = [1, 0]
const RUN = [0, 1]

encode(x) = Flux.argmax(x, [:walk, :run])

function load(;N=300)
    local filenames = readdir("./")

    local run_data = [(RUN, load_file(filename)) for filename in filter(is_run_file, filenames)]

    local walk_data = [(WALK, load_file(filename)) for filename in filter(is_walk_file, filenames)]

    local data = [walk_data; run_data]

    data = [[begin
                 range = i-N+1:i
                 (target, d[range, :])
             end for i in N:N:size(d, 1)]
            for (target, d) in data]

    data = vcat(data...)

    return data
end

function load_data(;
                   training_rate=0.6,
                   length_of_samples=100)
    @assert(training_rate < 1 && training_rate > 0)

    data = load(N=length_of_samples)
    local n = length(data)

    shuffle!(data)

    boundary = trunc(Integer, training_rate*n)

    training_data = data[1:boundary]
    test_data = data[boundary:n]

    return training_data, test_data
end
