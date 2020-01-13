import random
import sugar
import math
import strutils
import progress
import sequtils

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

  if softmax(-alpha*calc_E(x,w,cons),-alpha*calc_E(x2,w,cons)).a>=rand(1.0):
    return x2
  else:
    return x


proc bit2int(x:seq[int]):int=
  var a:int = 0
  for i in 1..4:
    a += x[i]*(2^(4-i))
  return a

proc int2bit(x:int):seq[int]=
  var a:string = x.toBin(4)
  var x = lc[0 | (_ <- 0..4),int]
  x[0] = 1
  for i in 1..4:
    if a[i-1]=='1':
      x[i] = 1
  return x

proc calc_distribution(xs:seq[seq[int]],w:seq[seq[float]],cons:float,alpha:float):seq[float]=
  var exp_x:seq[float] = lc[exp(-alpha*calc_E(x,w,cons))|(x <- xs),float]
  var sum_x:float = exp_x.foldl(a+b)
  return lc[(ex/sum_x)*1000|(ex<-exp_x),float]

var cons:float = 18
var alpha:float = 1
var x = lc[0 | (_ <- 0..4),int]
var ans = lc[0 | (_ <- 0..15),int]
var w = lc[lc[0 | (_ <- 0..4),float]|(_<-0..4), seq[float]]

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


var bar = newProgressBar(1000)
bar.start()
for _ in 0..1000:
  x[0] = 1
  for i in 1..4:
      x[i]=0

  for t in 1..100000:
    x=transition(x,w,cons,alpha)
  ans[bit2int(x)]+=1
  bar.increment()
bar.finish()

var dist:seq[float] = calc_distribution(lc[int2bit(i)|(i <- 0..15),seq[int]],w,cons,alpha)
for i in 0..15:
  echo "&" , ans[i]
