
package.path = package.path .. ";D:/Github/?/init.lua;D:/Github/?.lua"

require "PLoop"

-- Provide some useful functions to SpaUI
PLoop(function()

    import "System.Collections"
    import "System.Text.UTF8Encoding"

    -- Tools
    __Sealed__()
    class "Tools" {}

end)