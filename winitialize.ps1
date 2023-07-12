$items=@{}

# Read every json file below here, and bring into a hash keyed by service_name
Get-ChildItem -Path .\ -Filter *.json -Recurse -File -Name | ForEach-Object {
    $item = Get-Content -Path $_ -Raw |  ConvertFrom-Json
    $items[$item.service_name]=$item
}

# Are all prerequisites existing?
foreach ($h in $items.GetEnumerator()) {
    $name=$h.Key
    $prereqs = $h.Value.prerequisites
    foreach ($prereq in $prereqs) {
        if ( -not $items.ContainsKey($prereq))
        {
        throw "Invalid prerequisite: $name references non-existent '$prereq'"
        }
    }
}

# To rank the items, we give everything rank zero, then start promoting items based on their prerequisites' ranks. We stop when stability is achieved, or when we detect a circular ref (we went deeper than the total number of items

$max_depth = $items.Count

foreach ($e in $items.GetEnumerator()) {
    Add-Member -InputObject $e.Value -NotePropertyName rank -NotePropertyValue 0
}

$changed=$true
while ($changed) {
    $changed=$false
    foreach ($e in $items.GetEnumerator()) {
        $item=$e.Value
        $max_rank_prereq = ($item.prerequisites | foreach-object { $items[$_].rank } | Measure-Object -Max).Maximum
        if ( $max_rank_prereq -ge $item.rank ) {
            $changed=$true
            $item.rank = $max_rank_prereq + 1
            if ($item.rank -gt $max_depth) {
                throw "Circular dependency involving $($item.service_name)"
            }
        }
    }
}

$items
