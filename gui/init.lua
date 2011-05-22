local path = ({...})[1]:gsub("%.init", "") .. '.'
require(path .. 'gui')
require(path .. 'Control')
require(path .. 'Button')
require(path .. 'List')
require(path .. 'Panel')
require(path .. 'TextInput')
