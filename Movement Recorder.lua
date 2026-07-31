local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 120)
frame.Position = UDim2.new(0.5, -125, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Text = "Movement Recorder"
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

local recordButton = Instance.new("TextButton")
recordButton.Text = "Start Recording"
recordButton.Size = UDim2.new(0.5, -5, 0, 30)
recordButton.Position = UDim2.new(0, 5, 0, 30)
recordButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
recordButton.TextColor3 = Color3.fromRGB(255,255,255)
recordButton.Font = Enum.Font.SourceSans
recordButton.TextSize = 16
recordButton.Parent = frame

local replayButton = Instance.new("TextButton")
replayButton.Text = "Replay"
replayButton.Size = UDim2.new(0.5, -5, 0, 30)
replayButton.Position = UDim2.new(0.5, 0, 0, 30)
replayButton.BackgroundColor3 = Color3.fromRGB(0, 0, 150)
replayButton.TextColor3 = Color3.fromRGB(255,255,255)
replayButton.Font = Enum.Font.SourceSans
replayButton.TextSize = 16
replayButton.Parent = frame

local loopCheckbox = Instance.new("TextButton")
loopCheckbox.Text = "Loop: Off"
loopCheckbox.Size = UDim2.new(1, -10, 0, 25)
loopCheckbox.Position = UDim2.new(0, 5, 0, 65)
loopCheckbox.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
loopCheckbox.TextColor3 = Color3.fromRGB(255,255,255)
loopCheckbox.Font = Enum.Font.SourceSans
loopCheckbox.TextSize = 14
loopCheckbox.Parent = frame

local UserInputService = game:GetService("UserInputService")
local dragging = false
local dragInput, dragStart, startPos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
    end
end)

local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local runService = game:GetService("RunService")

local isRecording = false
local isReplaying = false
local recordedPositions = {}
local recordConnection = nil
local replayConnection = nil
local looping = false

loopCheckbox.MouseButton1Click:Connect(function()
    looping = not looping
    loopCheckbox.Text = "Loop: " .. (looping and "On" or "Off")
end)

recordButton.MouseButton1Click:Connect(function()
    if not isRecording then
        recordedPositions = {}
        isRecording = true
        recordButton.Text = "Stop Recording"
        recordButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        recordConnection = runService.Heartbeat:Connect(function()
            table.insert(recordedPositions, hrp.CFrame)
        end)
    else
        isRecording = false
        if recordConnection then recordConnection:Disconnect() end
        recordButton.Text = "Start Recording"
        recordButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end
end)

replayButton.MouseButton1Click:Connect(function()
    if #recordedPositions == 0 then
        print("No recorded data.")
        return
    end
    if not isReplaying then
        isReplaying = true
        replayButton.Text = "Stop"
        replayButton.BackgroundColor3 = Color3.fromRGB(150, 150, 0)
        local index = 1
        replayConnection = runService.Heartbeat:Connect(function()
            if index > #recordedPositions then
                if looping then
                    index = 1
                else
                    if replayConnection then replayConnection:Disconnect() end
                    isReplaying = false
                    replayButton.Text = "Replay"
                    replayButton.BackgroundColor3 = Color3.fromRGB(0, 0, 150)
                    return
                end
            end
            hrp.CFrame = recordedPositions[index]
            index = index + 1
        end)
    else
        if replayConnection then replayConnection:Disconnect() end
        isReplaying = false
        replayButton.Text = "Replay"
        replayButton.BackgroundColor3 = Color3.fromRGB(0, 0, 150)
    end
end)
