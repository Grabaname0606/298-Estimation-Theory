%% MAE 298 Estimation Project Matlab Script


%% Extended Kalman Filter: DP Model: 

% Import Battery Parameters 
BatteryParams    

% Import Kalman Parameters
KalmanParams

% Load Battery Measurements 
load('OCV_table.mat')
load('OCV_slope_table.mat')
load('IV_data_nonlinear.mat')

%%
% Initial Conditions: 
P(1) = 1;           % Covariance 
x1(1) = 0;          % SOC
x2(1) = 0;          % Vc1
x3(1) = 0;          % Vc2

x1_hat(1) = x1(1); 

for k = 2:length(t)
    
    x1(k) = Ad(1,1)*x1(k-1) + Bd(1,1)*I(k-1); % 
    x2(k) = Ad(2,2)*x2(k-1) + Bd(2,1)*I(k-1); %
    x3(k) = Ad(3,3)*x3(k-1) + Bd(3,1)*I(k-1); %
    
    C_ek =  interp1(soc_intpts_OCV_slope' ,OCV_slope_intpts,x1_hat(k-1));
    
    % Model Prediction: 
    x1_hat_prev = Ak*x1_hat(k-1)+Bk*I(k-1);
    P_prev = A_ek*P(k-1)*A_ek'+E_ek*Q*E_ek'; 
    
    % Measurement Update: 
    V_hat = interp1(soc_intpts_OCV' ,OCV_intpts,x1_hat(k-1)) -I(k-1)*R0-x2(k-1);
    L = P_prev*C_ek'*inv(C_ek*P_prev*C_ek'+F_ek*R*F_ek');
    
    x1_hat(k) = x1_hat_prev + L*(V(k)-V_hat); 
    P(k) = P_prev -L*C_ek*P_prev;   
    
end 



figure();
hold on 
plot(t,SOC_act)
plot(t,x1_hat)
plot(t,x1)
title('Problem #2 Extended Kalman Filter: SOC Results (Jonathan Dorsey)'); 
xlabel('Time (seconds)'); 
ylabel('State of Charge (SOC)'); 

legend('SOC Act','SOC Est','SOC_ OL');



Error = SOC_act-x1_hat';
sigma = sqrt(P(end)); 

int = linspace(-.02,.02, 3500); 

[f,x] = hist(Error,int); 
fx_pdf = pdf('norm',x,0,sigma); 

figure(); hold on; 
plot(x,f);
plot(x,fx_pdf,'r'); 
xlabel('Error') 
ylabel('Prob. Density');
legend('SOC Error','~N(0,P)'), title('SOC Error Distribution (Jonathan Dorsey)');


