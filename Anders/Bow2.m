%% KARPLUS STRING ALGORITHM
freq = 440;
fs = 44100;
noiseburstLength = 0.01;
Stringlength = floor(fs/freq);

%Interaction
InteractionPoint = 0.2;
BowForce = 0.3;
BowVelocity = 0.7;

WaveImpedance = 0.1;
StaticFrictionCoeff = 0.02;
DynamicFrictionCoeff = 0.01;

%Set up noiseburst
noiseburst = rand(1,fs*noiseburstLength);
noiseburst = noiseburst - mean(noiseburst);

%Set up delays of correct lengths in both directions
LengthToBridge = round(InteractionPoint*Stringlength);
LengthToNut = round((1-InteractionPoint)*Stringlength);
Delay1 = zeros(1,LengthToNut);
Delay2 = zeros(1,LengthToBridge);

for i = 1: 4*fs
    
    %PLUCK MODEL
    %Write the noise burst onto x, as long as we have a burst.
%     if i < length(noiseburst)
%         x = noiseburst(i);
%     else
%         x = 0;
%     end



    %Lowpass on both directions - moving avergae filter
    y1(i) = 0.497*Delay1(LengthToNut) + 0.497*Delay1(LengthToNut-1);
    y2(i) = 0.497*Delay2(LengthToBridge) + 0.497*Delay2(LengthToBridge-1);
 
    V = (Delay1(1)) + Delay1(end); %transverse velocity ('out' plus 'in' from one direction)   
    Vh = y1(end) + y2(end); %contribution of incoming waves ('in' summed from both directions)
    
    Tau = StaticFrictionCoeff + ((StaticFrictionCoeff - DynamicFrictionCoeff) + 0.7)/(0.7 + V - BowVelocity);
    
    friction = 2*WaveImpedance*(V-Vh);
    friction = Tau*(V-BowVelocity);
    
    %calculate new outgoing waves by...
    y1(i) = y2(end) + friction/(2*WaveImpedance);
    y2(i) = y1(end) + friction/(2*WaveImpedance);
    
    %Feed energy and oposite delay line into each line.
    Delay1 = [y2(i), Delay1(1:LengthToNut-1)];
    Delay2 = [y1(i), Delay2(1:LengthToBridge-1)];
    
    %Write output from lowpassed delays
    output(i) = (y1(i));
        
end

soundsc(output,fs);