





# Initialize an empty array to store the extracted URLs
$urls = @()


$testString = 't=2024-04-24T10:05:17-0500 lvl=info msg="started tunnel" obj=tunnels name=auth addr=https://localhost:44396 url=https://4ca8-76-10-70-110.ngrok-free.app'

# Iterate over each line and extract the URL using a regular expression

if ($testString -match "addr=([\S]+)") {
    $urls += $matches[1]
    if ($testString -match "url=([\S]+)") {
        $urls += $matches[1]
    }
    $urls
} 
  

# # Display the extracted URLs
# Write-Host "Extracted URLs:"
# $urls
# $lines
