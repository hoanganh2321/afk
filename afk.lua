-- AFK Rewards Configuration
local WEBHOOK_URL = "https://discord.com/api/webhooks/1330089734835277897/hdRecdjggab0Tr-wWdziRj32d78co06Y9oRnIPRM9XB-d0Tt5tV3lfACAuShtyRsXvqp"  -- Webhook URL sẽ được nhập từ UI
local CHECK_INTERVAL = 240 -- Check every 60 seconds
local lastRewardCount = 0 -- Track last known reward count

-- Function to send notification to Discord
local function sendToDiscord(rewardData)
    local timestamp = os.date("%d/%m/%Y %H:%M:%S")
    local embed = {
        title = "Arise Crossover - AFK Rewards",
        description = "Phần thưởng mới đã nhận được!",
        color = 0x00FF00, -- Green color
        fields = {
            {
                name = "Thông tin phần thưởng",
                value = "Phần thưởng mới:\n" .. rewardData.newRewards,
                inline = false
            },
            {
                name = "Tổng TICKETS",
                value = tostring(rewardData.totalTickets),
                inline = true
            },
            {
                name = "Thời gian",
                value = timestamp,
                inline = true
            },
            {
                name = "Người chơi",
                value = game.Players.LocalPlayer.Name,
                inline = true
            }
        },
        footer = {
            text = "Arise Crossover Rewards Tracker"
        }
    }

    local payload = {
        embeds = {embed},
        username = "Spidey Bot APP",
        content = "Hôm nay lúc " .. os.date("%H:%M")
    }

    local success, err = pcall(function()
        game:GetService("HttpService"):PostAsync(WEBHOOK_URL, game:GetService("HttpService"):JSONEncode(payload))
    end)

    if not success then
        warn("Failed to send to Discord: " .. err)
    end
end

-- Function to check AFK rewards
local function checkAFKRewards()
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local rewardGui = playerGui:FindFirstChild("AFKRewardGui") or playerGui:FindFirstChild("RewardGui")
    
    if rewardGui and rewardGui:FindFirstChild("ClaimButton") then
        -- Simulate clicking the claim button
        fireclickdetector(rewardGui.ClaimButton:FindFirstChildOfClass("ClickDetector"))
        
        -- Get reward information (this would need to be scraped from the UI)
        local newRewards = "- 5 TICKETS" -- Example, you'll need to get this from the UI
        local totalTickets = 81 -- Example, get from player stats
        
        -- Only send notification if tickets increased
        if totalTickets > lastRewardCount then
            sendToDiscord({
                newRewards = newRewards,
                totalTickets = totalTickets
            })
            lastRewardCount = totalTickets
        end
    end
end

-- Add AFK Rewards toggle to your UI
Tabs.Main:AddToggle("AutoAFKRewards", {
    Title = "Auto Claim AFK Rewards",
    Default = false,
    Callback = function(state)
        if state then
            -- Initial check
            checkAFKRewards()
            
            -- Set up recurring check
            while task.wait(CHECK_INTERVAL) and state do
                checkAFKRewards()
            end
        end
    end
})

-- Add webhook configuration input
Tabs.Settings:AddInput("DiscordWebhook", {
    Title = "Discord Webhook URL",
    Default = "",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(text)
        WEBHOOK_URL = text
        print("Webhook URL đã được cập nhật: " .. WEBHOOK_URL)
    end
})

-- Show UI to allow users to input webhook URL
Tabs.Main:AddButton("Show Webhook UI", function()
    local inputGui = Instance.new("ScreenGui")
    inputGui.Name = "WebhookInputGui"
    inputGui.Parent = game.Players.LocalPlayer.PlayerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.5, 0, 0.2, 0)
    frame.Position = UDim2.new(0.25, 0, 0.4, 0)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.Parent = inputGui

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0.2, 0)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.Text = "Nhập URL Webhook Discord:"
    textLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Parent = frame

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.8, 0, 0.3, 0)
    textBox.Position = UDim2.new(0.1, 0, 0.3, 0)
    textBox.PlaceholderText = "https://discord.com/api/webhooks/..."
    textBox.Parent = frame

    local submitButton = Instance.new("TextButton")
    submitButton.Size = UDim2.new(0.4, 0, 0.2, 0)
    submitButton.Position = UDim2.new(0.3, 0, 0.7, 0)
    submitButton.Text = "Submit"
    submitButton.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitButton.Parent = frame

    submitButton.MouseButton1Click:Connect(function()
        WEBHOOK_URL = textBox.Text
        print("Webhook URL đã được cập nhật: " .. WEBHOOK_URL)
        inputGui:Destroy()  -- Remove the input UI after submission
    end)
end)
