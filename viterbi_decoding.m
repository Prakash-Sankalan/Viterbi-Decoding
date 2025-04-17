clc;
clear;
% Define trellis using generator polynomials (g1 = 110, g2 = 111)
trellis = poly2trellis(3, [6 7]);
% Input and received sequences
inputBits = [1 0 1 1 0 0 0];
receivedBits = [0 1 1 1 0 1 1 1 0 1 0 1 1 1];
% Setup
numStates = 4;
numSteps = length(receivedBits) / 2;
pathMetric = inf(numStates, numSteps + 1);
pathMetric(1,1) = 0; % Start from state 00
survivor = zeros(numStates, numSteps + 1);
survivorPaths = cell(numStates, numSteps + 1);
survivorPaths{1,1} = [];
branchMetrics = zeros(numStates, 2, numSteps);
fprintf('=== Viterbi Decoding Process ===\n');
for step = 1:numSteps
   currentRx = receivedBits(2*step-1:2*step);
   fprintf('\nStage %d (Received: %d%d)\n', step, currentRx(1), currentRx(2));
  
   for state = 0:3
       prevStates = [bitshift(state, -1), bitshift(state, -1) + 2];
      
       for p = 1:2
           prevState = prevStates(p);
           inputBit = mod(state, 2);
           shiftReg = [inputBit, bitget(prevState,2), bitget(prevState,1)];
          
           out1 = mod(shiftReg * [1;1;0], 2);
           out2 = mod(shiftReg * [1;1;1], 2);
           expectedOutput = [out1 out2];
          
           metric = sum(xor(currentRx, expectedOutput));
           branchMetrics(state+1, p, step) = metric;
          
           totalMetric = pathMetric(prevState+1, step) + metric;
           if totalMetric < pathMetric(state+1, step+1)
               pathMetric(state+1, step+1) = totalMetric;
               survivor(state+1, step+1) = prevState;
               survivorPaths{state+1, step+1} = [survivorPaths{prevState+1, step} inputBit];
           end
          
           fprintf('State %d -> %d (input=%d): Output=%d%d, BM=%d\n', ...
               prevState, state, inputBit, out1, out2, metric);
       end
   end
  
   fprintf('\nPath Metrics after stage %d:\n', step);
   for s = 0:3
       fprintf('State %d%d: %d\n', bitget(s,2), bitget(s,1), pathMetric(s+1,step+1));
   end
  
   fprintf('\nSurvivor Paths:\n');
   for s = 0:3
       if ~isempty(survivorPaths{s+1,step+1})
           fprintf('State %d%d: %s\n', bitget(s,2), bitget(s,1), mat2str(survivorPaths{s+1,step+1}));
       end
   end
end
% Traceback
[~, finalState] = min(pathMetric(:, end));
decodedState = finalState - 1;
decodedBits = survivorPaths{finalState, end};
stateHistory = zeros(1, numSteps+1);
stateHistory(end) = decodedState;
for step = numSteps:-1:1
   stateHistory(step) = survivor(decodedState+1, step+1);
   decodedState = stateHistory(step);
end
fprintf('\n=== Final Decoding Results ===\n');
fprintf('Original message:    %s\n', mat2str(inputBits));
fprintf('Received sequence:   %s\n', mat2str(receivedBits));
fprintf('Decoded bit sequence: %s\n', mat2str(decodedBits));
fprintf('Final state: %d%d\n', bitget(finalState-1,2), bitget(finalState-1,1));
% Trellis diagram
figure;
hold on;
title('Trellis Diagram with Survivor Path');
xlabel('Time Step');
ylabel('State');
grid on;
yPositions = [4 3 2 1];
for step = 0:numSteps
   for state = 1:4
       plot(step, yPositions(state), 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'w');
   end
end
for step = 1:numSteps
   for state = 0:3
       prevStates = [bitshift(state, -1), bitshift(state, -1) + 2];
       for p = 1:2
           prevState = prevStates(p);
           x = [step-1 step];
           y = [yPositions(prevState+1) yPositions(state+1)];
           plot(x, y, 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5);
           midX = mean(x);
           midY = mean(y);
           text(midX, midY, num2str(branchMetrics(state+1, p, step)), ...
               'FontSize', 8, 'Color', 'b', 'HorizontalAlignment', 'center');
       end
   end
end
for step = 1:numSteps
   x = [step-1 step];
   y = [yPositions(stateHistory(step)+1) yPositions(stateHistory(step+1)+1)];
   inputBit = decodedBits(step);
   plot(x, y, 'r-', 'LineWidth', 2);
   midX = mean(x);
   midY = mean(y);
   text(midX, midY+0.15, sprintf('(%d)', inputBit), ...
       'Color', 'r', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
end
plot(0, yPositions(1), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
plot(numSteps, yPositions(finalState), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
yticks(1:4);
yticklabels({'00','01','10','11'});
xlim([-0.5 numSteps+0.5]);
ylim([0.5 4.5]);
hold off;
