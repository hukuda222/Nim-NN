import random
import sugar

randomize()

proc calc_E(x: seq[int], w: seq[seq[float]],cons: float): float =
  var E:float = 0
  for i1 in 0..4:
    for i2 in 0..4:
      E += w[i1][i2]*(x[i1]*x[i2]).float
  return -E/2+cons

proc update(x: seq[int], w: seq[seq[float]],i1: int): int =
  var new_score:float = 0
  for i2 in 0..4:
      new_score += w[i1][i2]*(x[i2]).float
  if new_score >= 0.0:
    return 1
  else:
    return 0


var x = lc[0 | (_ <- 0..4),int]
var w = lc[lc[0 | (_ <- 0..4),float]|(_<-0..4), seq[float]]
var cons:float = 10


w[0][1] = 0
w[0][2] = 15
w[0][3] = -4
w[0][4] = 10
w[1][2] = -2
w[1][3] = -6
w[1][4] = -6
w[2][3] = -6
w[2][4] = 8
w[3][4] = 2
for i in 0..4:
  for j in (i+1)..4:
    w[j][i]=w[i][j]
for i in 0..4:
  for j in 0..4:
    w[i][j] *= -1

x[0] = 1
for i in 1..4:
  x[i] = rand(0..1)

echo "initial state"
echo "x : "& $lc[x[i] | (i <- 1..4),int]
echo "E : "& $calc_E(x,w,cons)
var E:float = INF
var count:int = 0
while E!=0:
  for i in 1..4:
    x[i] = update(x,w,i)
    count += 1
    echo "after "& $count & "th transition, E : " & $calc_E(x,w,cons)
    echo "x : " & $lc[x[i] | (i <- 1..4),int]
    if calc_E(x,w,cons)==0:
      break
  E = calc_E(x,w,cons)

  let tmp_E:float = calc_E(x,w,cons)
  if tmp_E == E:
    break
  else:
    E = tmp_E

echo "state transition " & $count & " times"
echo "final state"
echo "x : "& $lc[x[i] | (i <- 1..4),int]
echo "E : "& $calc_E(x,w,cons)
