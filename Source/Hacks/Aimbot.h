#pragma once

#include <Config.h>
#include "../Memory.h"

namespace csgo
{
    struct UserCmd;
    struct Vector;
    struct ImDrawList;
}

class ClientInterfaces;
class EngineInterfaces;

class Aimbot {
public:
    static csgo::Vector calculateRelativeAngle(const csgo::Vector& source, const csgo::Vector& destination, const csgo::Vector& viewAngles) noexcept;
    void run(Misc& misc, const EngineInterfaces& engineInterfaces, const ClientInterfaces& clientInterfaces, const OtherInterfaces& interfaces, const Config& config, const Memory& memory, csgo::UserCmd*) noexcept;
    void drawFov(ImDrawList* drawList, const csgo::Engine& engine, const Config& config, const Memory& memory) noexcept;

    void updateInput(const Config& config) noexcept;
};
