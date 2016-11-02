require 'lib/class'
require 'lib/explicit-global'
require 'lib/table-utils'
require 'objects/factories/factory'
local generate_layout = require 'objects/factories/layouts/generator'

SmallFactory = class(Factory)
SmallFactory.LAYOUT = generate_layout("small")
SmallFactory.CONFIG = require('config').small_factory

function SmallFactory:layout_factory(room)
    Factory.layout_factory(self)
end

function SmallFactory:transfer_power()
    return Factory._transfer_power(self, self._entity, self._power)
end

return SmallFactory
