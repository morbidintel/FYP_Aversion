--application = {



if string.sub(system.getInfo("model"),1,4) == "iPad" then
    application = 
    {
        content =
        {
            width = 360,
            height = 480,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
        notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
    }

elseif string.sub(system.getInfo("model"),1,2) == "iP" and display.pixelHeight > 960 then
    application = 
    {
        content =
        {
            width = 320,
            height = 568,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
        notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
    }

elseif string.sub(system.getInfo("model"),1,2) == "iP" then
    application = 
    {
        content =
        {
            width = 320,
            height = 480,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
        notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
    }
elseif display.pixelHeight / display.pixelWidth > 1.72 then
	local aspectRatio = display.pixelHeight/display.pixelWidth
    application = 
    {
        content =
        {
			width = aspectRatio>1.5 and 320 or 480/aspectRatio,
			height = aspectRatio<1.5 and 480 or 320*aspectRatio,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            imageSuffix = 
            {
				["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
    }
else
	local aspectRatio = display.pixelHeight/display.pixelWidth
    application = 
    {
        content =
        {
			width = aspectRatio>1.5 and 320 or 480/aspectRatio,
			height = aspectRatio<1.5 and 480 or 320*aspectRatio,
            scale = "letterBox",
            xAlign = "center",
            yAlign = "center",
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
        notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
    }
end





































--[[
	local aspectRatio = display.pixelHeight/display.pixelWidth
	
	print("aspectRatio : "..aspectRatio)
	application = 
	{
		content = 
		{ 
			width = aspectRatio>1.5 and 320 or 480/aspectRatio,
			height = aspectRatio<1.5 and 480 or 320*aspectRatio,
			scale = "letterbox",
	 
			fps = 30,
	 
			imageSuffix =
			{
				["@2x"] = 2.0--,
				--["@4x"] = 3.0,
			},
		},
	}
]]--	
--[[
	content = {
		width = 320,
		height = 480, 
		--scale = "letterBox",
		fps = 30,
		
		
        imageSuffix = {
		    ["@2x"] = 2,
		}
		
	},
]]--
    --[[
    -- Push notifications

    notification =
    {
        iphone =
        {
            types =
            {
                "badge", "sound", "alert", "newsstand"
            }
        }
    }
    --]]    
--}
