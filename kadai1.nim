import random
import sugar

randomize()

proc calc_E(x: seq[int], w: seq[seq[float]]): float =
  var E:float = 0
  for i1 in 0..9:
    for i2 in 0..9:
        E += w[i1][i2]*(x[i1]*x[i2]).float
  return -E/2+1.75

proc update(x: seq[int], w: seq[seq[float]],i1:int): int =
  var new_score:float = 0
  for i2 in 0..9:
    new_score += w[i1][i2]*(x[i2]).float
  if new_score >= 0.0:
    return 1
  else:
    return 0


var x = lc[1 | (_ <- 0..9),int]
var w = lc[lc[0 | (_ <- 0..9),float]|(_<-0..9), seq[float]]


for i in 0..9:
  w[0][i] = 0.5
  w[i][0] = 0.5

for i in [1,4,7]:
  for j in 0..2:
    for k in 0..2:
      if j!=k:
        w[i+k][i+j] = -1
        w[i+j][i+k] = -1

for i in 1..3:
  for j in [0,3,6]:
    for k in [0,3,6]:
      if j!=k:
        w[i+j][i+k] = -1
        w[i+k][i+j] = -1
#for i in 0..9:
#  for j in (i+1)..9:
#    w[i][j] = rand(max=2.0) - 1.0


x[0] = 1
for i in 1..9:
  x[i] = rand(0..1)

echo "initial state"
echo "x : " & $lc[x[i] | (i <- 1..9),int]
echo "E : " & $calc_E(x,w)
var count:int = 0
var E:float = INF
while E!=0:
  for i in 1..9:
    x[i] = update(x,w,i)
    count += 1
    echo "after "& $count & "th transition, E : " & $calc_E(x,w)
    echo "x : " & $lc[x[i] | (i <- 1..9),int]
    if calc_E(x,w)==0:
      break
  E = calc_E(x,w)

echo "state transition " & $count & " times"
echo "x : " & $lc[x[i] | (i <- 1..9),int]
echo "E : " & $calc_E(x,w)
