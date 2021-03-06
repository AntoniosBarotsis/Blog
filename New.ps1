param(
    [Parameter(Mandatory=$true)] [String]$name
)

$path = ".\content\posts\$name"

New-Item -Path $path -ItemType Directory -ErrorAction Stop
New-Item -Path "$path\images" -ItemType Directory -ErrorAction Stop

$Tz = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

# This broke with daylight savings, hardcoded GMT+2
# $tmp = Get-TimeZone | Select-Object BaseUtcOffset
$tmp = [PSCustomObject]@{
    BaseGmtOffset = New-TimeSpan -Hours 2
}

$GmtOffset = "+{0:hh\:mm}" -f $tmp.BaseGmtOffset
$date = "$Tz$GmtOffset"

New-Item -Path "$path\index.md" -ItemType File -ErrorAction Stop

$text = @”
---
author: "Antonios Barotsis"
title: "$name"
description: ""
date: $date
tags: []
categories: []
# cover:
#     image: "images/"
draft: true
---

"@

$text | Out-File -Encoding UTF8 "$path\index.md"