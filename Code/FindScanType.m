function ScanType = FindScanType(mapsize,length)
if prod(mapsize) == length
    ScanType = 'Square';
elseif prod(mapsize)*3 == length
    ScanType = 'LGrid';
else
    ScanType = 'Hexagonal';
end