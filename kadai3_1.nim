import random
import sugar
import math

randomize()

proc calc_E(x: seq[int], w: seq[seq[float]],cons: float): float =
  var E:float = 0
  for i1 in 0..4:
    for i2 in 0..4:
      E += w[i1][i2]*(x[i1]*x[i2]).float
  return -E/2+cons

proc softmax(a: float,b:float):tuple[a:float,b:float]=
  var aa:float= exp(-a)
  var bb:float= exp(-b)
  return (aa/(aa+bb),bb/(aa+bb))


proc transition(x:seq[int],w:seq[seq[float]],cons:float,alpha:float):seq[int]=
  var xi:int = rand(1..4)
  var x2:seq[int] = x
  x2[xi] = ((x[xi]+1)mod 2)

  if softmax(-alpha*calc_E(x,w,cons),-alpha*calc_E(x2,w,cons)).a>=random(1.0):
    return x2
  else:
    return x


var x = lc[0 | (_ <- 0..4),int]
var w = lc[lc[0 | (_ <- 0..4),float]|(_<-0..4), seq[float]]
var cons:float = 18
var alpha:float = 1

w[0][1] = -16+6
w[0][2] = 12+3
w[0][3] = -4+4
w[0][4] = -16+4
w[1][2] = -4
w[1][3] = -4
w[1][4] = 8
w[2][3] = -2
w[2][4] = -6
w[3][4] = 0


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
echo "x : " &  $lc[x[i] | (i <- 1..4),int]
echo "E : " & $calc_E(x,w,cons)
for _ in 1..10000:
  x=transition(x,w,cons,alpha)
echo "final state"
echo "x : " &  $lc[x[i] | (i <- 1..4),int]
echo "E :" & $calc_E(x,w,cons)
