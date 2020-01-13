import random
import sugar
import math
import strutils
import progress
import sequtils

randomize()

proc calc_E(x: seq[int], w: seq[seq[float]],cons: float): float =
  var E:float = 0
  for i1 in 0..9:
    for i2 in 0..9:
      E += w[i1][i2]*(x[i1]*x[i2]).float
  return -E/2+cons

proc softmax(a: float,b:float):tuple[a:float,b:float]=
  var aa:float= exp(-a)
  var bb:float= exp(-b)
  return (aa/(aa+bb),bb/(aa+bb))


proc transition(x:seq[int],w:seq[seq[float]],cons:float,alpha:float):seq[int]=
  var xi:int = rand(1..9)
  var x2:seq[int] = x
  #for i in 1..9:
  #  x2[i] = rand(0..1)
  x2[xi] = ((x[xi]+1)mod 2)

  if softmax(-alpha*calc_E(x,w,cons),-alpha*calc_E(x2,w,cons)).a>=rand(1.0):
    return x2
  else:
    return x


proc bit2int(x:seq[int]):int=
  var a:int = 0
  for i in 1..9:
    a += x[i]*(2^(9-i))
  return a

proc int2bit(x:int):seq[int]=
  var a:string = x.toBin(9)
  var x = lc[0 | (_ <- 0..9),int]
  x[0] = 1
  for i in 1..9:
    if a[i-1]=='1':
      x[i] = 1
  return x

proc calc_distribution(xs:seq[seq[int]],w:seq[seq[float]],cons:float,alpha:float):seq[int]=
  var exp_x:seq[float] = lc[exp(-alpha*calc_E(x,w,cons))|(x <- xs),float]
  var sum_x:float = exp_x.foldl(a+b)
  return lc[((ex/sum_x)*100000).int|(ex<-exp_x),int]
  #return lc[calc_E(x,w,cons)|(x <- xs),float]

var cons:float = 1.75
var alpha:float = 1
var x = lc[0 | (_ <- 0..9),int]
var ans = lc[lc[0 | (_ <- 0..511),int]|(_<-1..5),seq[int]]
var dist = lc[lc[0 | (_ <- 0..511),int]|(_<-1..5),seq[int]]
var w = lc[lc[0 | (_ <- 0..9),float]|(_<-0..9), seq[float]]

for i in 0..9:
  w[0][i]=0.5
  w[i][0]=0.5

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

x[0] = 1
for i in 1..9:
    x[i]=rand(0..1)
for a in 1..3:
  if a==2:
    alpha = 20
  elif a==1:
    alpha = 5
  else:
    alpha = 1
  for t in 1..100000:
    x=transition(x,w,cons,alpha)
    ans[a][bit2int(x)]+=1

  dist[a] = calc_distribution(lc[int2bit(i)|(i <- 0..511),seq[int]],w,cons,alpha)
for i in 0..511:
  echo i.toBin(9),"&",ans[1][i],"&",dist[1][i],"&",ans[2][i],"&",dist[2][i],"&",ans[3][i],"&",dist[3][i],"\\\\"
