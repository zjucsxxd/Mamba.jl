#################### Direct Grid Sampler ####################

#################### Sampler Constructor ####################

function DGS(params::Vector{Symbol})
  Sampler(params,
    quote
      blockkeys = keys(model, :block, block)
      x = unlist(model, blockkeys)
      i = 0
      for key in blockkeys
        for d in [model[key].distr]
          i += 1
          f = function(v)
            x[i] = v
            logpdf!(model, x, block)
          end
          x[i] = dgs(grid(d), f)
        end
      end
      relist(model, x, blockkeys)
    end,
    ["sampler" => nothing]
  )
end


#################### Sampling Functions ####################

function dgs(grid::Vector, logf::Function)
  n = length(grid)
  p = Array(Float64, n)
  psum = 0.0
  for i in 1:n
    value = exp(logf(grid[i]))
    p[i] = value
    psum += value
  end
  if psum > 0
    p /= psum
  else
    p[:] = 1 / n
  end
  grid[rand(Categorical(p))]
end
