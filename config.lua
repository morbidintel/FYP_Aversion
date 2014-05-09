local originalWidth = 360
local originalHeight = 640
print(display.pixelWidth, display.pixelHeight)

application = 
{
	content =
	{
		width = originalWidth,
		height = originalHeight,
		scale = "letterBox",
		xAlign = "center",
		yAlign = "center",
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