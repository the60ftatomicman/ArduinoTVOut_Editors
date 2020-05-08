
param (
    #[Parameter(Mandatory=$true)][string]$service = 'payroll',
	[string]$filename = '.\test.bmp',
	[string]$logDir   ='.\output.txt'
)
cls
Add-Type -Assembly System.Drawing
$objBitmap = [System.Drawing.Bitmap]::FromFile((Resolve-Path $filename).ProviderPath)
$colors = @{
	'black'=@{eightBit="ff000000";twoBit="0";bcol="Black";fcol="White"};
	'white'=@{eightBit="ffffffff";twoBit="1";bcol="White";fcol="Black"};
}
## {X,Y,0x00,0xFF,etc}
## '{0:x1}' -f [Convert]::ToInt32('1111',2)
## How the notation works:
## The Y value is a 1 to 1 relationship. If we have 32 pixel rows, we need
## 32 "rows" in our array
## The X however needs to be divided by 8.
##
##
##
#$WindowSize        = $Host.UI.RawUI.WindowSize
#$MaxWindow         = $Host.UI.RawUI.MaxWindowSize
#$WindowSize.Width  = [Math]::Min($i.Width*5, $Host.UI.RawUI.BufferSize.Width)
#$WindowSize.Height = $MaxWindow.Height
#try{
#	$Host.UI.RawUI.WindowSize = $WindowSize
#}
#catch [System.Management.Automation.SetValueInvocationException] {
#	$Maxvalue = ($_.Exception.Message |Select-String "\d+").Matches[0].Value
#	$WindowSize.Height = $Maxvalue
#	$Host.UI.RawUI.WindowSize = $WindowSize
#}
#Test array should be opposite of (or just switch 0 and 1 on white vs black to se this pattern!):
# 0xF8,0x00
# 0xF8,0x00
# 0xF8,0x00
# 0xF8,0x00
# 0xF8,0x00
# 0x07,0xC0
# 0x05,0x40
# 0x07,0xC0
# 0x05,0x40
# 0x07,0xC0
Write-Host "---------- Reading Bitmap ----------"
$totalHex=[Math]::Ceiling([Math]::Ceiling($objBitmap.Width/8)*$objBitmap.Height)
$objMemory=New-Object 'string[]' $totalHex
$curHex=0
Write-Host "-- Expect ["$totalHex" ] memory maps"
$curWord = "";
for ($h=0; $h -lt $objBitmap.Height; $h++) {
	for ($w=0; $w -lt $objBitmap.Width; $w++) {
		$name  = $objBitmap.GetPixel($w,$h).Name
		$color = $colors.black
		if($name -eq $colors.white.eightBit){
			$color = $colors.white
		}
		$curWord += $color.twoBit
		if($curWord.length -eq 8 -or ($w -eq $objBitmap.Width-1) ){
			$curWord = $curWord.PadRight(8,'0')
			$hexOne = '{0:x1}' -f [Convert]::ToInt32($curWord.Substring(0,4),2)
			$hexTwo = '{0:x1}' -f [Convert]::ToInt32($curWord.Substring(4,4),2)
			$hexCombined = ("0x"+$hexOne+$hexTwo).Replace(" ","")
			Write-Host $curWord' HEX['($curHex+1)']: '$hexCombined
			$objMemory[$curHex]=$hexCombined
			$curHex++
			$curWord = ""
		}
	}
}
Write-Host ''
#
Write-Host "---------- Building Bitmap ----------"
Write-Host "{"
Write-Host $objBitmap.Width","$objBitmap.Height","
for ($h=0; $h -lt $objMemory.length; $h++) {
	$hex = $objMemory[$h]
	Write-Host $hex -NoNewLine
	if($h -ne ($objMemory.length - 1)){
		Write-Host "," -NoNewLine
	}else{
		Write-Host ""
	}
}
Write-Host "}"