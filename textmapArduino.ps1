
param (
    #[Parameter(Mandatory=$true)][string]$service = 'payroll',
	[string]$filename = '.\alphabet.png',
	[string]$logDir   = '.\output.txt',
	[int]$letterH     = 6,
	[int]$letterW     = 8,
	[int]$starIdx     = 33
)
cls
Add-Type -Assembly System.Drawing
$objBitmap = [System.Drawing.Bitmap]::FromFile((Resolve-Path $filename).ProviderPath)
$colors = @{
	'black'=@{eightBit="ff000000";twoBit="0";bcol="Black";fcol="White"};
	'white'=@{eightBit="ffffffff";twoBit="1";bcol="White";fcol="Black"};
}
$characters=@(
# startIDX 0
'space','!','"','#','$','%','&',"'",'(',')','*','+',',','-','.','/',
# startIDX 16
'0','1','2','3','4','5','6','7','8','9',':',
# startIDX 27
';','<','=','>','?','@',
# startIDX 33
'A','B','C','D','E','F','G',
'H','I','J','K','L','M','N',
'O','P','Q','R','S','T','U',
'V','W','X','Y','Z',
# startIDX 59
'[','\\',']','^','_','tick',
# startIDX 65
'a','b','c','d','e','f','g',
'h','i','j','k','l','m','n',
'o','p','q','r','s','t','u',
'v','w','x','y','z',
'{','|','}','~'
)
Write-Host "---------- Reading Bitmap ----------"
Write-Host "-- Picture W["$objBitmap.Width"]xH["$objBitmap.Height"], Letters W["$letterW"]xH["$letterH"]"
Write-Host "---------- Diagnostics -------------"
$totalLetters=[Math]::Floor($objBitmap.Width/$letterW)*[Math]::Floor($objBitmap.Height/$letterH)
$objMemory=New-Object 'string[]' $totalLetters	
Write-Host "-- Expect ["$totalLetters" ] Letters, Starting at Character ["$starIdx"]"
Write-Host "-- Remember only White and Black pixels counted!"
Write-Host "-- Remember we assume GAPS of 1px between letters"
Write-Host "---------- Building Characters -----------------"
$charIdx = $starIdx;
$boxW    = $letterW+1
$boxH    = $letterH+1
for ($h=0; $h -lt $objBitmap.Height; $h+=$boxH) {
	for ($w=0; $w -lt $objBitmap.Width; $w+=$boxW) {
		'// '+$characters[$charIdx]
		$charIdx++
		for ($ph=$h; $ph -lt $h+$letterH; $ph++) {
			$curLine = "0b";
			for ($pw=$w; $pw -lt $w+$letterW; $pw++) {
				$name  = $objBitmap.GetPixel($pw,$ph).Name
				$color = $colors.black
				if($name -eq $colors.white.eightBit){
					$color = $colors.white
				}
				$curLine = $curLine+$color.twoBit
			}
			Write-Host $curLine","
		}
	}
}
Write-Host ''