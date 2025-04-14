local api = require 'api' -- load API

api.reset()               -- Clear all registers

-- Calculate: 79 - 8
api.load(79)
api.add()
api.load(8)
api.subtract()
