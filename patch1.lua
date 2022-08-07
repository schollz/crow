--  input 1: gate
--  input 2: nothing
-- output 1: adsr (from gate)
-- output 2: oscillator at 220 hz
-- output 3: lfo 1-4 for s&h
-- output 4: gate for s&h

function init()
  local threshold=1.0
  local hysteresis=0.1
  output[1].action=adsr(0.1,0.5,5,1)
  output[2](oscillate(220,10,'sine'))
  output[3].slew=0
  output[4].action=pulse(0.03,10)

  input[1].mode('change',threshold,hysteresis,'both')
  input[1].change=function(state)
    print(state)
    output[1](state)
  end
  clock.run(forever)
end

function forever()
  local lfos={}
  for i=1,4 do
    table.insert(lfos,math.random(1,1000)/100)
  end
  local ct=0
  local dt=0.05
  while true do
    for i=1,4 do
      output[3].volts=linlin(get_lfo(ct,lfos[i],0),-1,1,0,10)
      clock.sleep(dt/2)
      output[4]()
      clock.sleep(dt/2)
      ct=ct+dt
    end
  end
end

function get_lfo(current_time,period,offset)
  if period==0 then
    return 1
  else
    return math.sin(2*math.pi*current_time/period+offset)
  end
end

function linlin(f,slo,shi,dlo,dhi)
  if f<=slo then
    return dlo
  elseif f>=shi then
    return dhi
  else
    return (f-slo)/(shi-slo)*(dhi-dlo)+dlo
  end
end
