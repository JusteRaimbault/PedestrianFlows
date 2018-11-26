

turtles-own [
  id-path
  delay
  goal ; useless???

  speed-max
  speed-t
  age
  has-arrived?
  count-interaction
]

patches-own [
  shortest-path-min
  shortest-path-t
  obstacle
    safe?
  finished?

  id-special
  interaction
  speed-patch
  presence
]

globals [
 repartition-among-paths
 ;meanage
 direction
 max-speed-patch
 path-mean-interaction ;
 interaction-maxpatch ; compteur sortie : nombre d'interactions maximum sur un patch
  interaction-meanpatch ; compteur sortie : nombre d'interactions moyenne sur un patch
path-time-mean
 path-time-fast ; compteur sortie :
]







to draw
  if mouse-down?  [
    let p patch round mouse-xcor round mouse-ycor

    ask  p [
     if id-special = 1 [

      if obstacleGreen? and not obstacleRed? [set obstacle [0 1]
        set pcolor green + 3.5]
      if obstacleRed? and not obstacleGreen? [set obstacle [1 0]
        set pcolor red + 3.5]
      if obstacleRed? and obstacleGreen? [set obstacle [1 1]
        set pcolor black]
      if not obstacleRed? and not obstacleGreen? [set obstacle [0 0]
        set pcolor 9.2]
      ;set obstacle 1
      ]
    ]
  ]

end




to mark-safe [id]
  if mouse-down? [
    mark-safe-patch id patch round mouse-xcor round mouse-ycor

  ]
end

to mark-safe-patch [id p]

    ask p [
      set safe? replace-item id safe? true

    ]


end

to mark-safe-patches [id listp]

    ask listp [
     set safe? replace-item id safe? true
    ]
end

to flood-fill [id]
  ; based on dijkstra algorithm and netlogo "patch-tools"
  ask patches with [item (item id direction) obstacle = 0] [set finished? false
    ]
   ask patches with [item (item id direction) obstacle = 1] [
    set finished? true
  ]
   ask patches with [item id safe? = true] [
    set shortest-path-min replace-item id shortest-path-min 0
    set finished? true
  ]
  while [any? patches with [finished? = false and item (item id direction) obstacle = 0]] [

  ask patches with [finished? = true and item (item id direction) obstacle = 0] [
   let temp self
    ask neighbors with [finished? != true and item (item id direction) obstacle = 0] [
     let distemp distance temp
     let new (([item id shortest-path-min] of myself) + distemp / speed-patch)

     if (new < item id shortest-path-min or item id shortest-path-min = 0)
      [set shortest-path-min replace-item id shortest-path-min new]

    if distemp = 1 [
      set finished? true
    ]
    ]
  ]

  ]


end

to color-patches-with-interaction
  color-patches-with-environment
  let maxI max [log (interaction + 1) 10] of patches
  ask patches with [pcolor = 9.2] [set pcolor scale-color violet log (interaction + 1) 10  maxI 0]
end
to color-patches-with-presence
  color-patches-with-environment
  let maxP max [log (presence + 1) 10] of patches
  ask patches with [pcolor = 9.2 or sum obstacle = 1] [set pcolor scale-color cyan log (presence + 1) 10  maxP 0]
end



to color-patches-with-shortest-path [id]
  color-patches-with-environment
  if id = -1 [stop]
  let maxC max [item id shortest-path-t] of patches
  let minC min [item id shortest-path-t] of patches

  ask patches with [item (item id direction) obstacle = 0] [set pcolor scale-color yellow item id shortest-path-t maxC minC]
  ask patches with [item (item id direction) obstacle = 1] [set pcolor black]
end







to setup-part1
  clear-all
  reset-ticks
  setup-globals

   ask patches [
  set shortest-path-min [0 0 0 0 0 0 0 0 0 0]
  set obstacle [0 0 0 0 0 0 0 0 0 0]
  set safe? [false false false false false false false false false false] ; temporary
   ]
   import-image

end


to setup-part2
 setup-space
  setup-turtles-simple

end
to setup-globals
  set repartition-among-paths [0.143 0.214 0.285 0.428 0.571 0.714 0.785 0.856 0.927 1]
  set direction [0 0 0 1 1 0 0 0 1 1]
end

to go

  regrow-shortest-path

  let i 0
  ask turtles with [delay <= ticks] [
    if hidden? = true and not has-arrived? [set hidden? false]
    set i id-path
     if [item i safe?] of patch-here [

       set has-arrived? true
       set hidden? true]
     if not has-arrived? [
     set age age + 1
     ]
  ]

  ask turtles with [(can-play? (speed-t) ([speed-patch] of patch-here)) and delay <= ticks and not has-arrived?] [

    downhill-shortest-path id-path
    temporary-increase-shortest-path id-path
  ]
  ifelse count turtles with [not has-arrived?] > 0 [tick]
  [;
  ]
  ask patches [
    set presence presence + count turtles-here
  ]
end



to-report can-play? [s sp]
  let temp1 random-float ratio-speed-fast-slow
  let temp2 random-float max-speed-patch

  report temp1 < s and temp2 < sp
end
to import-image
  import-pcolors input_image;"ligne4v8_modif3.bmp"
  ask patches [set id-special 1]
  ask patches with [pcolor = 0] [set obstacle [1 1]
    set id-special 0]
  if existing-obstacles [
  ask patches with [pcolor = 4.5] [set obstacle [1 1]
  ]
  ask patches with [pcolor = 14.9] [set obstacle [1 0]
]
  ask patches with [pcolor = 105] [set obstacle [0 1]
   ]
  ]

  ask patches with [pcolor = 44.9] [set id-special "A"]
  ask patches with [pcolor = 126] [set id-special "B"]
  ask patches with [pcolor = 118.1] [set id-special "C"]
  ask patches with [pcolor = 12.9] [set id-special "D"]
  ask patches with [pcolor = 64.3] [set id-special "E"]
  ask patches with [pcolor = 35.6] [set id-special "F"]
  ask patches with [pcolor = 44.3] [set id-special "G"]
  ask patches with [pcolor = 137.1] [set id-special "H"]
  ;id-special

  ask patches [set speed-patch 1]
   ask patches with [pcolor = 25.6] [set speed-patch 1.75]

   ask patches with [pcolor = 106.5] [set speed-patch 0.75]

  if existing-obstacles [
   ask patches with [pcolor = 14.9] [set speed-patch speed-at-booth]
   ask patches with [pcolor = 105] [set speed-patch speed-at-booth]
  ]

  color-patches-with-environment

  set max-speed-patch max [speed-patch] of patches
end


to color-patches-with-environment
  ask patches [set pcolor 9.2]

  ask patches with [is-string? id-special] [set pcolor 3]
  ask patches with [speed-patch > 1] [set pcolor white
    set plabel-color black
    set plabel "x"]
  ask patches with [speed-patch < 1] [set pcolor white
    set plabel-color black
    set plabel "+"]
   ask patches with [sum obstacle = 2] [set pcolor black]
  ask patches with [obstacle = [1 0]] [set pcolor red + 3.5
    set plabel ""]
  ask patches with [obstacle = [0 1]] [set pcolor green + 3.5
    set plabel ""]

end

to setup-space

    mark-safe-patches 0 patches with [id-special = "C"]
    flood-fill 0
    mark-safe-patches 1 patches with [id-special = "F"]
    flood-fill 1
    mark-safe-patches 2 patches with [id-special = "F"]
    flood-fill 2
    mark-safe-patches 3 patches with [id-special = "H"]
    flood-fill 3
    mark-safe-patches 4 patches with [id-special = "A"]
    flood-fill 4
    mark-safe-patches 5 patches with [id-special = "C"]
    flood-fill 5
    mark-safe-patches 6 patches with [id-special = "F"]
    flood-fill 6
    mark-safe-patches 7 patches with [id-special = "C"]
    flood-fill 7
    mark-safe-patches 8 patches with [id-special = "A"]
    flood-fill 8
    mark-safe-patches 9 patches with [id-special = "H"]
    flood-fill 9

   ask patches [
     set shortest-path-t shortest-path-min
     ]

end

to setup-turtles-simple
  create-turtles number-of-persons [
    set hidden? true
    set delay who * 10 / flow-rate-of-persons
    let temp100 random-float 100
    ifelse temp100 < percentage-slow-persons [
      set speed-max 1
      set shape "person slow"
    ][
    set speed-max ratio-speed-fast-slow
    set shape "person"
    ]
    set speed-t speed-max
    set has-arrived? false
    let temp random-float 1
    set id-path  position-in-list temp repartition-among-paths
    set size (world-height + world-width) / 70


  ]
ask turtles with [id-path = 0] [
  move-to one-of patches with [id-special = "G"]
  set delay period-between-trains * random (number-of-persons * 10 / flow-rate-of-persons / period-between-trains); + delay mod period-between-trains
  ]



ask turtles with [id-path = 1] [
  move-to one-of patches with [id-special = "G"]
   set delay period-between-trains * random  (number-of-persons * 10 / flow-rate-of-persons / period-between-trains); + delay mod period-between-trains
  ]
ask turtles with [id-path = 2] [
  move-to one-of patches with [id-special = "D"]]
ask turtles with [id-path = 3] [
  move-to one-of patches with [id-special = "D"]]
ask turtles with [id-path = 4] [
  move-to one-of patches with [id-special = "D"]]
ask turtles with [id-path = 5] [
  move-to one-of patches with [id-special = "B"]
   set delay (period-between-trains / 2) + period-between-trains * random  (number-of-persons * 10 / flow-rate-of-persons / period-between-trains); + delay mod period-between-trains
  ]
ask turtles with [id-path = 6] [
  move-to one-of patches with [id-special = "B"]
   set delay (period-between-trains / 2) + period-between-trains * random  (number-of-persons * 10 / flow-rate-of-persons / period-between-trains); + delay mod period-between-trains
  ]
ask turtles with [id-path = 7] [
  move-to one-of patches with [id-special = "E"]]
ask turtles with [id-path = 8] [
  move-to one-of patches with [id-special = "E"]]
ask turtles with [id-path = 9] [
  move-to one-of patches with [id-special = "E"]]
color-turtles -1
end

to-report mean-age [id t]
ifelse t = "slow" [
  ifelse id = -1
  [
    if any? turtles with [has-arrived? = true and speed-t = 1] [  report mean [age] of turtles with [has-arrived? = true and speed-t = 1]]
  ]
  [
   if any? turtles with [has-arrived? = true and speed-t = 1 and id-path = id] [ report mean [age] of turtles with [has-arrived? = true and speed-t = 1 and id-path = id]]
  ]
]
[
    ifelse id = -1
  [
  if any? turtles with [has-arrived? = true and speed-t > 1] [ report mean [age] of turtles with [has-arrived? = true and speed-t > 1]]
  ]
  [
   if any? turtles with [has-arrived? = true and speed-t > 1  and id-path = id] [ report mean [age] of turtles with [has-arrived? = true and speed-t > 1 and id-path = id]]
  ]
]
report 0
end

to-report mean-interaction [id t]
ifelse t = "slow" [
  ifelse id = -1
  [
  if any? turtles with [has-arrived? = true and speed-t = 1] [ report mean [count-interaction / age] of turtles with [has-arrived? = true and speed-t = 1]]
  ]
  [
   if any? turtles with [has-arrived? = true and speed-t = 1 and id-path = id] [ report mean [count-interaction / age] of turtles with [has-arrived? = true and speed-t = 1 and id-path = id]]
  ]
]
[
    ifelse id = -1
  [
  if any? turtles with [has-arrived? = true and speed-t > 1] [ report mean [count-interaction / age] of turtles with [has-arrived? = true and speed-t > 1]]
  ]
  [
   if any? turtles with [has-arrived? = true and speed-t > 1 and id-path = id] [ report mean [count-interaction / age] of turtles with [has-arrived? = true and speed-t > 1 and id-path = id]]
  ]
]
report 0
end



to color-turtles [id]

  ask turtles with [id-path = 0] [set color green]
  ask turtles with [id-path = 1] [set color green]
  ask turtles with [id-path = 2] [set color red]
  ask turtles with [id-path = 3] [set color red]
  ask turtles with [id-path = 4] [set color red]
  ask turtles with [id-path = 5] [set color green]
  ask turtles with [id-path = 6] [set color green]
  ask turtles with [id-path = 7] [set color red]
  ask turtles with [id-path = 8] [set color red]
  ask turtles with [id-path = 9] [set color red]
  ask turtles with [id-path = id] [set color blue]
end

to-report position-in-list [tempR repartition-among-pathsR]
  let i 0
  while [i < length repartition-among-pathsR] [
   if tempR < item i repartition-among-pathsR [
     report i
   ]
   set i i + 1
  ]
  report 0
end

to downhill-shortest-path [id]

    let tempI 0
    ;move-to max-one-of patches in-cone 1 180 [item id shortest-path-t]
    let temp min-one-of neighbors with [item (item id direction) obstacle = 0] [item id shortest-path-t]
    let ok? true
    ask temp [
      if item (item id direction) obstacle > 0 [set ok? false]
    if count turtles-here  with [delay <= ticks and not has-arrived?] > 0 [;?
      set ok? false
      set interaction interaction + 1
      set tempI 1
     ;
      ]
    ]
    ifelse ok? [
      set heading towards temp
      move-to temp]
    [
       let temp2 min-one-of neighbors with [item (item id direction) obstacle = 0 and pxcor != [pxcor] of temp and pycor != [pycor] of temp] [item id shortest-path-t]
    let ok?2 true
    if is-patch? temp2 [ask temp2 [
      if item (item id direction) obstacle > 0 [set ok? false]
    if count turtles-here with [delay <= ticks and has-arrived? = false] > 0 [
    ;  set interaction interaction + 1
     ; set tempI 1
      set ok? false]
    ]
    if ok?2 [
      set heading towards temp2
      move-to temp2
      ]]

      if not ok?2 [if any? neighbors with [item (item id direction) obstacle = 0 and turtles-here with [delay <= ticks and has-arrived? = false] = 0] [
        move-to one-of neighbors with [item (item id direction) obstacle = 0 and turtles-here with [delay <= ticks and has-arrived? = false] = 0]
      ]
    ]
    ]
    set count-interaction count-interaction + tempI

end


to temporary-increase-shortest-path [id]
  let i 0
  if [sum obstacle] of patch-here = 1 [
    set heading heading + 180
   if is-patch? patch-ahead radius  [
     fd radius
   ask patches in-radius radius  [
    set i 0
    while [i < length repartition-among-paths]
    [
    if i != id [
      set shortest-path-t replace-item i shortest-path-t min list (item i shortest-path-min + 3 * intensity) (item i shortest-path-t + intensity); (max [(item i shortest-path-t + intensity), (item i shortest-path-min + 2 * intensity)])
    ]
    set i i + 1
    ]
  ]
  fd -1 * radius
   ]
   set heading heading + 180
  ]
   ask patch-here [

      set shortest-path-t replace-item id shortest-path-t min list (item id shortest-path-min + 3 * intensity) (item id shortest-path-t + intensity); (max [(item i shortest-path-t + intensity), (item i shortest-path-min + 2 * intensity)])
]

   if is-patch? patch-ahead radius  [
     fd radius
   ask patches in-radius radius  [
    set i 0
    while [i < length repartition-among-paths]
    [
    if i != id [
      set shortest-path-t replace-item i shortest-path-t min list (item i shortest-path-min + 3 * intensity) (item i shortest-path-t + intensity); (max [(item i shortest-path-t + intensity), (item i shortest-path-min + 2 * intensity)])
    ]
    set i i + 1
    ]
  ]
  fd -1 * radius
   ]
end


to reportGlobals
  let i 0
   set path-mean-interaction []
    while [i < length repartition-among-paths]
    [
      set  path-mean-interaction lput mean-interaction i "fast" path-mean-interaction
    set i i + 1
    ]

    set i 0
   set path-time-fast []
    while [i < length repartition-among-paths]
    [
      set  path-time-fast lput mean-age i "fast" path-time-fast
    set i i + 1
    ]
       set interaction-meanpatch  sum [interaction] of patches / count turtles with [ticks >= delay]
 set path-time-mean mean [age] of turtles
 set interaction-maxpatch  max [interaction] of patches
end



to regrow-shortest-path
  ask patches [
    let i 0
    while [i < length repartition-among-paths]
    [
      if item i shortest-path-t != item i shortest-path-min [
      set shortest-path-t replace-item i shortest-path-t max list (item i shortest-path-min) (item i shortest-path-t - regrow-speed)
    ]
    set i i + 1
    ]

  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
8
21
616
379
-1
-1
4.823
1
10
1
1
1
0
0
0
1
0
123
0
67
0
0
1
ticks
30.0

BUTTON
186
433
284
467
NIL
setup-part1
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
454
483
590
561
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
130
587
218
621
mark-safe
mark-safe path-number - 1
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
304
435
440
489
NIL
draw
T
1
T
PATCH
NIL
NIL
NIL
NIL
1

MONITOR
1219
52
1355
97
Total number of paths
length repartition-among-paths
17
1
11

SLIDER
872
54
983
87
path-number
path-number
0
10
0
1
1
NIL
HORIZONTAL

BUTTON
463
431
566
466
NIL
setup-part2
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
999
58
1215
92
color-patches-with-shortest-path
color-patches-with-shortest-path path-number - 1\ncolor-turtles path-number - 1
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
83
435
174
469
NIL
ca\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
636
307
809
340
intensity
intensity
0
10
3
0.1
1
NIL
HORIZONTAL

SLIDER
634
264
807
297
radius
radius
1
4
2.5
0.1
1
NIL
HORIZONTAL

SLIDER
99
522
271
555
number-of-persons
number-of-persons
10
10000
390
10
1
NIL
HORIZONTAL

SLIDER
641
372
813
405
regrow-speed
regrow-speed
0
10
1
0.1
1
NIL
HORIZONTAL

BUTTON
829
402
1027
436
NIL
color-patches-with-interaction
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1040
487
1250
532
Path average time for slow persons
mean-age (path-number - 1) \"slow\"
1
1
11

TEXTBOX
638
23
788
41
Parameters
11
0.0
1

TEXTBOX
868
29
919
48
Outputs
11
0.0
1

TEXTBOX
650
240
800
258
Behaviour
11
0.0
1

TEXTBOX
636
47
786
65
Global environment
11
0.0
1

TEXTBOX
645
348
795
366
Local environment
11
0.0
1

SWITCH
302
494
445
527
obstacleGreen?
obstacleGreen?
1
1
-1000

SWITCH
305
532
441
565
obstacleRed?
obstacleRed?
1
1
-1000

SWITCH
110
482
267
515
existing-obstacles
existing-obstacles
0
1
-1000

SLIDER
627
121
818
154
percentage-slow-persons
percentage-slow-persons
0
100
50
1
1
NIL
HORIZONTAL

SLIDER
635
159
808
192
ratio-speed-fast-slow
ratio-speed-fast-slow
1
5
2
0.1
1
NIL
HORIZONTAL

SLIDER
625
75
798
108
flow-rate-of-persons
flow-rate-of-persons
1
100
8.5
0.1
1
NIL
HORIZONTAL

MONITOR
1039
367
1274
412
Max number of interactions in one patch
max [interaction] of patches
1
1
11

MONITOR
1040
437
1247
482
Path average time for fast persons
mean-age (path-number - 1) \"fast\"
1
1
11

MONITOR
1043
540
1363
585
Path interactions counted per time unit for fast persons
mean-interaction (path-number - 1) \"fast\"
2
1
11

MONITOR
1045
593
1365
638
Path interactions counter per time unit for slow persons
mean-interaction (path-number - 1) \"slow\"
2
1
11

PLOT
629
455
1022
644
Number of persons
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"on-site" 1.0 0 -955883 true "" "plotxy ticks count turtles with [delay <= ticks and has-arrived? = false]"
"arrived" 1.0 0 -13345367 true "" "plotxy ticks count turtles with [delay <= ticks and has-arrived?]"
"not-started" 1.0 0 -1184463 true "" "plotxy ticks count turtles with [delay > ticks]"

PLOT
868
102
1295
350
Path average time for fast persons
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"path1" 1.0 0 -13840069 true "" "plotxy ticks mean-age (0) \"fast\""
"path2" 1.0 0 -13840069 true "" "plotxy ticks mean-age (1) \"fast\""
"path3" 1.0 0 -7500403 true "" "plotxy ticks mean-age (2) \"fast\""
"path4" 1.0 0 -2674135 true "" "plotxy ticks mean-age (3) \"fast\""
"path5" 1.0 0 -2674135 true "" "plotxy ticks mean-age (4) \"fast\""
"path6" 1.0 0 -13840069 true "" "plotxy ticks mean-age (5) \"fast\""
"path7" 1.0 0 -13840069 true "" "plotxy ticks mean-age (6) \"fast\""
"path8" 1.0 0 -7500403 true "" "plotxy ticks mean-age (7) \"fast\""
"path9" 1.0 0 -2674135 true "" "plotxy ticks mean-age (8) \"fast\""
"path10" 1.0 0 -2674135 true "" "plotxy ticks mean-age (9) \"fast\""

TEXTBOX
1043
415
1180
433
for path : path-number
11
0.0
1

SLIDER
638
412
810
445
speed-at-booth
speed-at-booth
0.1
1
0.8
0.05
1
NIL
HORIZONTAL

BUTTON
824
362
1013
395
NIL
color-patches-with-presence
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
635
200
808
233
period-between-trains
period-between-trains
10
1000
300
10
1
NIL
HORIZONTAL

CHOOSER
234
579
423
624
input_image
input_image
"ligne4v8.bmp" "ligne4v8_modif1.bmp"
0

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

CA : clear-all
setup-part1
(draw) if you want to modify the environment
setup-part2
go

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
LE NECHET 2015
Université Paris Est
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person slow
false
0
Polygon -7500403 true true 120 90 90 90 60 195 90 210 105 135 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 135 210 210 240 195 210 90 180 90 150 90
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true false 210 225 210 300 285 270 285 195
Rectangle -13791810 true false 180 225 210 300
Polygon -14835848 true false 180 226 210 225 285 195 255 196
Polygon -13345367 true false 209 202 209 216 244 202 243 188
Rectangle -13791810 true false 30 225 60 300
Polygon -13345367 true false 60 225 60 300 135 270 135 195
Polygon -14835848 true false 30 226 60 225 135 195 105 196
Polygon -13345367 true false 59 202 59 216 94 202 93 188

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="15" runMetricsEveryStep="false">
    <setup>ca
setup-part1
setup-part2</setup>
    <go>go
reportGlobals</go>
    <timeLimit steps="10000"/>
    <exitCondition>count turtles with [has-arrived? = false] = 0</exitCondition>
    <metric>path-time-mean</metric>
    <metric>interaction-meanpatch</metric>
    <metric>path-mean-interaction</metric>
    <metric>path-time-fast</metric>
    <metric>interaction-maxpatch</metric>
    <enumeratedValueSet variable="number-of-persons">
      <value value="700"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regrow-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="obstacleRed?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="flow-rate-of-persons">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="intensity">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ratio-speed-fast-slow">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="path-number">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input_image">
      <value value="&quot;ligne4v8.bmp&quot;"/>
      <value value="&quot;ligne4v8_modif1.bmp&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentage-slow-persons">
      <value value="10"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="radius">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="existing-obstacles">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="obstacleGreen?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
