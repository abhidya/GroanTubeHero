local PolarLayout = {}

function PolarLayout.position(radius, angleDeg, y)
    local radians = math.rad(angleDeg or 0)
    return Vector3.new(math.cos(radians) * (radius or 0), y or 0, math.sin(radians) * (radius or 0))
end

function PolarLayout.cframeFacingCenter(radius, angleDeg, y)
    local pos = PolarLayout.position(radius, angleDeg, y)
    return CFrame.lookAt(pos, Vector3.new(0, y or 0, 0))
end

function PolarLayout.cframeFacingOut(radius, angleDeg, y)
    local pos = PolarLayout.position(radius, angleDeg, y)
    local flat = Vector3.new(pos.X, 0, pos.Z)
    local out
    if flat.Magnitude <= 0.001 then
        out = pos + Vector3.new(1, 0, 0)
    else
        out = pos + flat.Unit
    end
    return CFrame.lookAt(pos, out)
end

function PolarLayout.distribute(count, radius, y, startAngleDeg)
    local result = {}
    local n = math.max(1, count or 1)
    for i = 1, n do
        local angle = (startAngleDeg or 0) + ((i - 1) * 360 / n)
        result[i] = {
            index = i,
            angleDeg = angle % 360,
            position = PolarLayout.position(radius, angle, y),
            cframeFacingCenter = PolarLayout.cframeFacingCenter(radius, angle, y),
            cframeFacingOut = PolarLayout.cframeFacingOut(radius, angle, y),
        }
    end
    return result
end

return PolarLayout
