-- PriestShadow.lua
-- October 2022

if UnitClassBase( "player" ) ~= "PRIEST" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local FindUnitBuffByID, FindUnitDebuffByID, PTR = ns.FindUnitBuffByID, ns.FindUnitDebuffByID, ns.PTR

local spec = Hekili:NewSpecialization( 258 )

spec:RegisterResource( Enum.PowerType.Insanity, {
    mind_flay = {
        aura = "mind_flay",
        debuff = true,

        last = function ()
            local app = state.buff.casting.applied
            local t = state.query_time

            return app + floor( ( t - app ) / class.auras.mind_flay.tick_time ) * class.auras.mind_flay.tick_time
        end,

        interval = function () return class.auras.mind_flay.tick_time end,
        value = 2,
    },

    mind_flay_insanity = {
        aura = "mind_flay_insanity_dot",
        debuff = true,

        last = function ()
            local app = state.buff.casting.applied
            local t = state.query_time

            return app + floor( ( t - app ) / class.auras.mind_flay_insanity_dot.tick_time ) * class.auras.mind_flay_insanity_dot.tick_time
        end,

        interval = function () return class.auras.mind_flay_insanity_dot.tick_time end,
        value = 4,
    },

    mind_sear = {
        channel = "mind_sear",

        last = function ()
            local app = state.buff.casting.applied
            local t = state.query_time

            return app + floor( ( t - app ) / class.auras.mind_sear.tick_time ) * class.auras.mind_sear.tick_time
        end,

        interval = function () return class.auras.mind_sear.tick_time end,
        value = function ()
            if state.buff.mind_devourer_ms_active.up then return 0 end
            return -25
        end,
    },

    void_torrent = {
        channel = "void_torrent",

        last = function ()
            local app = state.buff.casting.applied
            local t = state.query_time

            return app + floor( ( t - app ) / class.abilities.void_torrent.tick_time ) * class.abilities.void_torrent.tick_time
        end,

        interval = function () return class.abilities.void_torrent.tick_time end,
        value = 15,
    },

    mindbender = {
        aura = "mindbender",

        last = function ()
            local app = state.buff.mindbender.expires - 15
            local t = state.query_time

            return app + floor( ( t - app ) / ( 1.5 * state.haste ) ) * ( 1.5 * state.haste )
        end,

        interval = function () return 1.5 * state.haste * ( state.conduit.rabid_shadows.enabled and 0.85 or 1 ) end,
        value = 3
    },

    shadowfiend = {
        aura = "shadowfiend",

        last = function ()
            local app = state.buff.shadowfiend.expires - 15
            local t = state.query_time

            return app + floor( ( t - app ) / ( 1.5 * state.haste ) ) * ( 1.5 * state.haste )
        end,

        interval = function () return 1.5 * state.haste * ( state.conduit.rabid_shadows.enabled and 0.85 or 1 ) end,
        value = 3
    },

    death_and_madness = {
        aura = "death_and_madness",

        last = function ()
            local app = state.buff.death_and_madness.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = 1,
        value = 7.5,
    },

    vampiric_touch = {
        talent = "maddening_touch",
        aura = "vampiric_touch",
        debuff = true,

        last = function ()
            local app = state.debuff.vampiric_touch.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = function() return class.auras.vampiric_touch.tick_time end,
        value = function() return state.talent.maddening_touch.rank end,
    }
} )
spec:RegisterResource( Enum.PowerType.Mana )


-- Talents
spec:RegisterTalents( {
    -- Priest
    angelic_bulwark            = { 82675, 108945, 1 }, -- When an attack brings you below 30% health, you gain an absorption shield equal to 15% of your maximum health for 20 sec. Cannot occur more than once every 90 sec.
    angelic_feather            = { 82703, 121536, 1 }, -- Places a feather at the target location, granting the first ally to walk through it 40% increased movement speed for 5 sec. Only 3 feathers can be placed at one time.
    angels_mercy               = { 82678, 238100, 1 }, -- Damage you take reduces the cooldown of Desperate Prayer, based on the amount of damage taken.
    apathy                     = { 82689, 390668, 1 }, -- Your Mind Blast critical strikes reduce your target's movement speed by 75% for 4 sec.
    binding_heals              = { 82678, 368275, 1 }, -- 20% of Flash Heal healing on other targets also heals you.
    blessed_recovery           = { 82720, 390767, 1 }, -- After being struck by a melee or ranged critical hit, heal 20% of the damage taken over 6 sec.
    body_and_soul              = { 82706, 64129 , 1 }, -- Power Word: Shield and Leap of Faith increase your target's movement speed by 40% for 3 sec.
    crystalline_reflection     = { 82681, 373457, 2 }, -- Power Word: Shield instantly heals the target for 690 and reflects 10% of damage absorbed.
    death_and_madness          = { 82711, 321291, 1 }, -- If your Shadow Word: Death fails to kill a target at or below 20% health, its cooldown is reset. Cannot occur more than once every 20 sec. If a target dies within 7 sec after being struck by your Shadow Word: Death, you gain 30 Insanity over 4 sec.
    dispel_magic               = { 82715, 528   , 1 }, -- Dispels Magic on the enemy target, removing 1 beneficial Magic effect.
    dominate_mind              = { 82710, 205364, 1 }, -- Controls a mind up to 1 level above yours for 30 sec while still controlling your own mind. Does not work versus Demonic, Mechanical, or Undead beings or players. This spell shares diminishing returns with other disorienting effects.
    focused_mending            = { 82719, 372354, 1 }, -- Prayer of Mending does 45% increased healing to the initial target.
    from_darkness_comes_light  = { 82707, 390615, 1 }, -- Each time Shadow Word: Pain deals damage, the healing of your next Flash Heal is increased by 1%, up to a maximum of 50%.
    holy_nova                  = { 82701, 132157, 1 }, -- An explosion of holy light around you deals up to 569 Holy damage to enemies and up to 517 healing to allies within 12 yds, reduced if there are more than 5 targets.
    improved_fade              = { 82686, 390670, 2 }, -- Reduces the cooldown of Fade by 5 sec.
    improved_flash_heal        = { 82714, 393870, 1 }, -- Increases healing done by Flash Heal by 15%.
    improved_mass_dispel       = { 82698, 341167, 1 }, -- Mass Dispel's cooldown is reduced to 25 sec and its cast time is reduced by 1 sec.
    inspiration                = { 82696, 390676, 1 }, -- Reduces your target's physical damage taken by 5% for 15 sec after a critical heal with Flash Heal.
    leap_of_faith              = { 82716, 73325 , 1 }, -- Pulls the spirit of a party or raid member, instantly moving them directly in front of you.
    lights_inspiration         = { 82679, 373450, 2 }, -- Increases the maximum health gained from Desperate Prayer by 8%.
    manipulation               = { 82672, 390996, 2 }, -- Your Mind Blast, Mind Flay, and Mind Spike casts reduce the cooldown of Mindgames by 0.5 sec.
    mass_dispel                = { 82699, 32375 , 1 }, -- Dispels magic in a 15 yard radius, removing all harmful Magic from 5 friendly targets and 1 beneficial Magic effect from 5 enemy targets. Potent enough to remove Magic that is normally undispellable.
    mind_control               = { 82710, 605   , 1 }, -- Controls a mind up to 1 level above yours for 30 sec. Does not work versus Demonic, Undead, or Mechanical beings. Shares diminishing returns with other disorienting effects.
    mindgames                  = { 82687, 375901, 1 }, -- Assault an enemy's mind, dealing 5,086 Shadow damage and briefly reversing their perception of reality. For 7 sec, the next 6,165 damage they deal will heal their target, and the next 6,165 healing they deal will damage their target. Generates 10 Insanity.
    move_with_grace            = { 82702, 390620, 1 }, -- Reduces the cooldown of Leap of Faith by 30 sec.
    petrifying_scream          = { 82695, 55676 , 1 }, -- Psychic Scream causes enemies to tremble in place instead of fleeing in fear.
    phantasm                   = { 82556, 108942, 1 }, -- Activating Fade removes all snare effects.
    power_infusion             = { 82694, 10060 , 1 }, -- Infuses the target with power for 20 sec, increasing haste by 25%. Can only be cast on players.
    power_word_life            = { 82676, 373481, 1 }, -- A word of holy power that heals the target for 2,466. If the target is below 35% health, Power Word: Life heals for 400% more and the cooldown of Power Word: Life is reduced by 20 sec.
    protective_light           = { 82707, 193063, 1 }, -- Casting Flash Heal on yourself reduces all damage you take by 10% for 10 sec.
    psychic_voice              = { 82695, 196704, 1 }, -- Reduces the cooldown of Psychic Scream by 15 sec.
    rhapsody                   = { 82700, 390622, 1 }, -- For every 5 sec that you do not cast Holy Nova, the damage of your next Holy Nova is increased by 10% and its healing is increased by 20%. This effect can stack up to 20 times.
    sanguine_teachings         = { 82691, 373218, 1 }, -- Increases your Leech by 5%.
    sanlayn                    = { 82690, 199855, 1 }, --  Sanguine Teachings Sanguine Teachings grants an additional 2% Leech.  Vampiric Embrace Reduces the cooldown of Vampiric Embrace by 45 sec, increases its healing done by 25%.
    shackle_undead             = { 82693, 9484  , 1 }, -- Shackles the target undead enemy for 50 sec, preventing all actions and movement. Damage will cancel the effect. Limit 1.
    shattered_perceptions      = { 82673, 391112, 1 }, -- Mindgames lasts an additional 2 sec, deals an additional 25% initial damage, and reverses an additional 25% damage or healing.
    sheer_terror               = { 82708, 390919, 1 }, -- Increases the amount of damage required to break your Psychic Scream by 75%.
    spell_warding              = { 82720, 390667, 1 }, -- Reduces all magic damage taken by 3%.
    surge_of_light             = { 82677, 109186, 2 }, -- Your healing spells and Smite have a 4% chance to make your next Flash Heal instant and cost no mana. Stacks to 2.
    throes_of_pain             = { 82709, 377422, 2 }, -- Shadow Word: Pain deals an additional 3% damage. When an enemy dies while afflicted by your Shadow Word: Pain, you gain 3 Insanity.
    tithe_evasion              = { 82688, 373223, 1 }, -- Shadow Word: Death deals 75% less damage to you.
    translucent_image          = { 82685, 373446, 1 }, -- Fade reduces damage you take by 10%.
    twins_of_the_sun_priestess = { 82683, 373466, 1 }, -- Power Infusion also grants you 100% of its effects when used on an ally.
    twist_of_fate              = { 82684, 390972, 2 }, -- After damaging or healing a target below 35% health, gain 5% increased damage and healing for 8 sec.
    unwavering_will            = { 82697, 373456, 2 }, -- While above 75% health, the cast time of your Flash Heal is reduced by 5%.
    vampiric_embrace           = { 82691, 15286 , 1 }, -- Fills you with the embrace of Shadow energy for 15 sec, causing you to heal a nearby ally for 62% of any single-target Shadow spell damage you deal.
    void_shield                = { 82692, 280749, 1 }, -- When cast on yourself, 30% of damage you deal refills your Power Word: Shield.
    void_shift                 = { 82674, 108968, 1 }, -- You and the currently targeted party or raid member swap health percentages. Increases the lower health percentage of the two to 25% if below that amount.
    void_tendrils              = { 82708, 108920, 1 }, -- Summons shadowy tendrils, rooting up to 5 enemy targets within 8 yards for 20 sec or until the tendril is killed.
    words_of_the_pious         = { 82721, 377438, 1 }, -- For 12 sec after casting Power Word: Shield, you deal 10% additional damage and healing with Smite and Holy Nova.

    -- Shadow
    ancient_madness            = { 82656, 341240, 2 }, -- Voidform and Dark Ascension increase your critical strike chance by 10% for 20 sec, reducing by 0.5% every sec.
    auspicious_spirits         = { 82667, 155271, 1 }, -- Your Shadowy Apparitions now deal 15% increased damage and generate 1 Insanity.
    coalescing_shadows         = { 82653, 391242, 1 }, -- Mind Sear and Shadow Word: Pain damage has a 4% chance to grant you Coalescing Shadows and Mind Flay has a 15% chance to grant you Coalescing Shadows, stacking up to 3 times. Mind Blast and Mind Spike consume all Coalescing Shadows to deal 10% increased damage per stack, and consuming at least 1 increases the damage of your periodic effects by 10% for 15 sec.
    damnation                  = { 82654, 341374, 1 }, -- Instantly afflicts the target with Shadow Word: Pain, Vampiric Touch and Devouring Plague.
    dark_ascension             = { 82657, 391109, 1 }, -- Increases your non-periodic Shadow damage by 25% for 20 sec. Generates 30 Insanity.
    dark_evangelism            = { 82660, 391095, 2 }, -- Your Mind Flay, Mind Sear, and Void Torrent damage increases the damage of your periodic Shadow effects by 1%, stacking up to 5 times.
    dark_void                  = { 82650, 263346, 1 }, -- Unleashes an explosion of dark energy around your target, dealing 1,352 Shadow damage and applying Shadow Word: Pain to your target and 15 nearby enemies. Generates 15 Insanity.
    deathspeaker               = { 82558, 392507, 1 }, -- Your Shadow Word: Pain damage has a chance to reset the cooldown of Shadow Word: Death and enable 150% additional damage regardless of the target's health.
    devouring_plague           = { 82665, 335467, 1 }, -- Afflicts the target with a disease that instantly causes 2,807 Shadow damage plus an additional 3,284 Shadow damage over 6 sec. Heals you for 30% of damage dealt. If this effect is reapplied, any remaining damage will be added to the new Devouring Plague.
    dispersion                 = { 82663, 47585 , 1 }, -- Disperse into pure shadow energy, reducing all damage taken by 75% for 6 sec and healing you for 25% of your maximum health over its duration, but you are unable to attack or cast spells. Increases movement speed by 50% and makes you immune to all movement impairing effects. Castable while stunned, feared, or silenced.
    divine_star                = { 82680, 122121, 1 }, -- Throw a Divine Star forward 27 yds, healing allies in its path for 1,151 and dealing 1,012 Shadow damage to enemies. After reaching its destination, the Divine Star returns to you, healing allies and damaging enemies in its path again. Healing reduced beyond 6 targets. Generates 6 Insanity.
    encroaching_shadows        = { 82562, 391235, 1 }, -- Increases the initial damage of Devouring Plague by 75% and the damage of Mind Sear by 20%.
    halo                       = { 82680, 120644, 1 }, -- Creates a ring of Shadow energy around you that quickly expands to a 30 yd radius, healing allies for 2,647 and dealing 2,607 Shadow damage to enemies. Healing reduced beyond 6 targets. Generates 10 Insanity.
    harnessed_shadows          = { 82647, 391296, 1 }, -- Increases the chance for you to gain a Coalescing Shadow when dealing damage with Mind Sear and Shadow Word: Pain by 2% and Mind Flay by 10%. You have a 100% chance to gain a Coalescing Shadow when critically hit by any attack. This effect can only occur every 6 sec.
    idol_of_cthun              = { 82643, 377349, 1 }, -- Mind Flay and Mind Sear have a chance to spawn a Void Tendril or Void Lasher that channels at your target for 15 sec, generating 2 Insanity every 1 sec.
    idol_of_nzoth              = { 82552, 373280, 1 }, -- Your periodic Shadow Word: Pain and Vampiric Touch damage has a 30% chance to apply Echoing Void, max 4 targets. Each time Echoing Void is applied, it has a chance to collapse, consuming a stack every 1 sec to deal 198 Shadow damage to all nearby enemies. Damage reduced beyond 5 targets. If an enemy dies with Echoing Void, all stacks collapse immediately.
    idol_of_yoggsaron          = { 82555, 373273, 1 }, -- After conjuring Shadowy Apparitions, gain a stack of Idol of Yogg-Saron. At 25 stacks, you summon a Thing from Beyond that serves you for 20 sec. The Thing from Beyond blasts enemies for 2,179 Shadow damage and deals 30% of that damage to all enemies within 10 yards. Damage reduced beyond 5 targets.
    idol_of_yshaarj            = { 82553, 373310, 1 }, -- Summoning Shadowfiend causes you to gain a benefit based on your target's current state or increases its duration by 5 sec if no state matches. Healthy: You and your Shadowfiend deal 5% additional damage. Enraged: Devours the Enraged effect, increasing your Haste by 5%. Stunned: Generates 5 Insanity every 1 sec. Feared: You and your Shadowfiend deal 5% increased damage and do not break Fear effects.
    inescapable_torment        = { 82644, 373427, 2 }, -- Mind Blast and Shadow Word: Death cause your Mindbender to teleport behind your target, slashing up to 5 nearby enemies for 1,670 Shadow damage and increasing the duration of Mindbender by 1.0 sec.
    insidious_ire              = { 82560, 373212, 2 }, -- While you have Shadow Word: Pain, Devouring Plague, and Vampiric Touch active on the same target, your Mind Blast deals 20% more damage.
    intangibility              = { 82659, 288733, 1 }, -- Dispersion heals you for an additional 25% of your maximum health over its duration and its cooldown is reduced by 30 sec.
    last_word                  = { 82652, 263716, 1 }, -- Reduces the cooldown of Silence by 15 sec.
    maddening_touch            = { 82645, 391228, 2 }, -- Vampiric Touch has a 50% chance to generate 1 Insanity each time it deals damage.
    malediction                = { 82655, 373221, 2 }, -- Reduces the cooldown of Damnation and Void Torrent by 15 sec.
    mental_decay               = { 82661, 375994, 1 }, -- The duration of your Shadow Word: Pain and Vampiric Touch is increased by 1 sec when enemies suffer Mind Flay or Mind Sear damage.
    mental_fortitude           = { 82659, 377065, 1 }, -- Healing from Vampiric Touch and Devouring Plague when you are at maximum health will shield you for the same amount. Shield cannot exceed 3,934 damage absorbed.
    mind_devourer              = { 82561, 373202, 2 }, -- Mind Blast has a 15% chance to make your next Devouring Plague or Mind Sear cost no insanity.
    mind_flay_insanity         = { 82558, 391399, 1 }, -- Devouring Plague transforms your next Mind Flay into Mind Flay: Insanity. Lasts 10 sec.  Mind Flay: Insanity Assaults the target's mind with Shadow energy, causing 5,170 Shadow damage over 2.4 sec and slowing their movement speed by 70%. Generates 16 Insanity over the duration.
    mind_melt                  = { 82559, 391090, 1 }, -- Mind Spike reduces the cast time of your next Mind Blast by 50% and increases its critical strike chance by 25%, stacking up to 2 times. Lasts 10 sec.
    mind_sear                  = { 82664, 48045 , 1 }, -- 25 Insanity every 0.6 sec Channeled Corrosive shadow energy radiates from the target, dealing 6,053 Shadow damage over 2.4 sec to all enemies within 10 yards of the target.
    mind_spike                 = { 82668, 73510 , 1 }, -- Blasts the target for 1,098 Shadowfrost damage. Generates 4 Insanity.
    mindbender                 = { 82648, 200174, 1 }, -- Summons a Mindbender to attack the target for 15 sec. Generates 3 Insanity each time the Mindbender attacks.
    misery                     = { 82650, 238558, 1 }, -- Vampiric Touch also applies Shadow Word: Pain to the target. Shadow Word: Pain lasts an additional 5 sec.
    pain_of_death              = { 82671, 391288, 2 }, -- Increases the damage dealt by Shadow Word: Death by 13%. Shadow Word: Death deals 20% of its damage to all targets affected by your Shadow Word: Pain within 40 yards.
    prayer_of_mending          = { 82718, 33076 , 1 }, -- Places a ward on an ally that heals them for 1,002 the next time they take damage, and then jumps to another ally within 20 yds. Jumps up to 4 times and lasts 30 sec after each jump.
    psychic_horror             = { 82652, 64044 , 1 }, -- Terrifies the target in place, stunning them for 4 sec.
    psychic_link               = { 82670, 199484, 2 }, -- Mind Blast, Mind Flay, Mind Spike, Mindgames, Void Bolt, and Void Torrent deal 30% of their damage to all other targets afflicted by your Vampiric Touch within 40 yards.
    puppet_master              = { 82646, 377387, 1 }, -- Your Shadowfiend and Mindbender grant you Coalescing Shadows each time they deal damage. Damage from your Shadowy Apparitions has a 8% chance to grant you Coalescing Shadows.
    purify_disease             = { 82704, 213634, 1 }, -- Removes all Disease effects from a friendly target.
    renew                      = { 82717, 139   , 1 }, -- Fill the target with faith in the light, healing for 3,765 over 15 sec.
    screams_of_the_void        = { 82649, 375767, 2 }, -- While channeling Mind Flay or Void Torrent, your Vampiric Touch and Shadow Word: Pain on your primary target deals damage 40% faster. While channeling Mind Sear, your Vampiric Touch and Shadow Word: Pain on all targets deals damage 41% faster.
    shadow_crash               = { 82557, 205385, 1 }, -- Hurl a bolt of slow-moving Shadow energy at the destination, dealing 3,804 Shadow damage to all targets within 8 yards and applying Vampiric Touch to 8 of them. Generates 15 Insanity.
    shadow_word_death          = { 82712, 32379 , 1 }, -- A word of dark binding that inflicts 1,692 Shadow damage to the target. If the target is not killed by Shadow Word: Death, the caster takes damage equal to the damage inflicted upon the target. Damage increased by 150% to targets below 20% health.
    shadowfiend                = { 82713, 34433 , 1 }, -- Summons a shadowy fiend to attack the target for 15 sec. Generates 3 Insanity each time the Shadowfiend attacks.
    shadowy_apparitions        = { 82666, 341491, 1 }, -- Mind Blast, Devouring Plague, and Void Bolt have a 100% chance to conjure Shadowy Apparitions and Mind Sear has a 50% chance to conjure Shadowy Apparitions. Shadowy Apparitions float towards all targets afflicted by your Vampiric Touch for 428 Shadow damage. Critical strikes with Mind Blast, Devouring Plague, and Void Bolt increase the damage of the Shadowy Apparitions they conjure by 100%.
    shadowy_insight            = { 82662, 375888, 1 }, -- Mind Blast gains an additional charge. Shadow Word: Pain periodic damage has a chance to reset the remaining cooldown on Mind Blast and cause your next Mind Blast to be instant.
    silence                    = { 82651, 15487 , 1 }, -- Silences the target, preventing them from casting spells for 4 sec. Against non-players, also interrupts spellcasting and prevents any spell in that school from being cast for 4 sec.
    surge_of_darkness          = { 82669, 162448, 1 }, -- Your Vampiric Touch and Devouring Plague damage has a chance to cause your next Mind Spike to be instant cast and deal 200% additional damage. Stacks up to 3 times.
    tormented_spirits          = { 82667, 391284, 1 }, -- Your Shadow Word: Pain damage has a 5% chance to create Shadowy Apparitions that float towards all targets afflicted by your Vampiric Touch. Critical strikes increase the chance to 10%.
    unfurling_darkness         = { 82658, 341273, 1 }, -- After casting Vampiric Touch on a target, your next Vampiric Touch within 8 sec is instant cast and deals 3,145 Shadow damage immediately. This effect cannot occur more than once every 15 sec.
    void_eruption              = { 82657, 228260, 1 }, -- Releases an explosive blast of pure void energy, activating Voidform and causing 2,570 Shadow damage to all enemies within 10 yds of your target. During Voidform, this ability is replaced by Void Bolt. Each 25 Insanity spent during Voidform increases the duration of Voidform by 1.0 sec.
    void_torrent               = { 82654, 263165, 1 }, -- Channel a torrent of void energy into the target, dealing 13,693 Shadow damage over 3 sec. Generates 60 Insanity over the duration.
    whispers_of_the_damned     = { 82563, 391137, 2 }, -- Your Mind Blast and Mind Spike critical strikes generate an additional 3 Insanity.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    cardinal_mending    = 5474, -- (328529) Prayer of Mending's healing is increased by 50% and its jump range is increased by 10 yds.
    catharsis           = 5486, -- (391297) 20% of all damage you take is stored. The stored amount cannot exceed 15% of your maximum health. The initial damage of your next Shadow Word: Pain deals this stored damage to your target.
    delivered_from_evil = 5481, -- (196611) Leap of Faith removes all movement impairing effects, and increases your next heal on that target by 100%.
    driven_to_madness   = 106 , -- (199259) While Voidform or Dark Ascension is not active, being attacked will reduce the cooldown of Void Eruption and Dark Ascension by 3 sec.
    eternal_rest        = 5484, -- (322107) Reduces the cooldown of Shadow Word: Death by 12 sec.
    mind_trauma         = 113 , -- (199445) Fully-channeled Mind Flays cause you to steal 3% haste from the target for 20 sec. Only 12% haste can be stolen from a single target. Stacks up to 8 times.
    precognition        = 5500, -- (377360) If an interrupt is used on you while you are not casting, gain 15% haste and become immune to control and interrupt effects for 4 sec.
    psyfiend            = 763 , -- (211522) Summons a Psyfiend with 4,096 health for 12 sec beside you to attack the target at range with Psyflay.  Psyflay Deals up to 1% of the target's total health in Shadow damage every 0.8 sec. Also slows their movement speed by 50% and reduces healing received by 50%.
    strength_of_soul    = 5477, -- (197535) Your Power Word: Shield reduces all Physical damage taken by 15% while the shield persists.
    thoughtsteal        = 5381, -- (316262) Peer into the mind of the enemy, attempting to steal a known spell. If stolen, the victim cannot cast that spell for 20 sec. Can only be used on Humanoids with mana. If you're unable to find a spell to steal, the cooldown of Thoughtsteal is reset.
    void_origins        = 739 , -- (228630) Void Eruption and Dark Ascension are now instant cast.
    void_volley         = 5447, -- (357711) After casting Void Eruption or Dark Ascension, send a slow-moving bolt of Shadow energy at a random location every 0.5 sec for 3 sec, dealing 1,650 Shadow damage to all targets within 8 yds, and causing them to flee in Horror for 3 sec.
} )


spec:RegisterTotem( "mindbender", 136214 )
spec:RegisterTotem( "shadowfiend", 136199 )

local mind_devourer_consumed = 0
local thought_harvester_consumed = 0
local unfurling_darkness_triggered = 0

local swp_applied = 0

spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == GUID then
        if subtype == "SPELL_AURA_REMOVED" then
            if spellID == 373204 then
                mind_devourer_consumed = GetTime()
            elseif spellID == 288343 then
                thought_harvester_consumed = GetTime()
            elseif spellID == 341207 then
                Hekili:ForceUpdate( subtype )
            end

        elseif subtype == "SPELL_AURA_APPLIED" then
            if spellID == 341273 then
                unfurling_darkness_triggered = GetTime()
            elseif spellID == 341207 then
                Hekili:ForceUpdate( subtype )
            end
        end
    end
end, false )


local ExpireVoidform = setfenv( function()
    applyBuff( "shadowform" )
    if Hekili.ActiveDebug then Hekili:Debug( "Voidform expired, Shadowform applied.  Did it stick?  %s.", buff.voidform.up and "Yes" or "No" ) end
end, state )


spec:RegisterGear( "tier29", 200327, 200329, 200324, 200326, 200328 )
spec:RegisterAuras( {
    dark_reveries = {
        id = 394963,
        duration = 8,
        max_stack = 1
    },
    gathering_shadows = {
        id = 394961,
        duration = 15,
        max_stack = 3
    }
} )


spec:RegisterHook( "reset_precast", function ()
    if buff.voidform.up or time > 0 then
        applyBuff( "shadowform" )
    end

    if unfurling_darkness_triggered > 0 and now - unfurling_darkness_triggered < 15 then
        applyBuff( "unfurling_darkness_icd", now - unfurling_darkness_triggered )
    end

    if pet.mindbender.active then
        applyBuff( "mindbender", pet.mindbender.remains )
        buff.mindbender.applied = action.mindbender.lastCast
        buff.mindbender.duration = 15
        buff.mindbender.expires = action.mindbender.lastCast + 15
    elseif pet.shadowfiend.active then
        applyBuff( "shadowfiend", pet.shadowfiend.remains )
        buff.shadowfiend.applied = action.shadowfiend.lastCast
        buff.shadowfiend.duration = 15
        buff.shadowfiend.expires = action.shadowfiend.lastCast + 15
    end

    if talent.mindbender.enabled then
        cooldown.fiend = cooldown.mindbender
        pet.fiend = pet.mindbender
    else
        cooldown.fiend = cooldown.shadowfiend
        pet.fiend = pet.mindbender
    end

    if buff.voidform.up then
        state:QueueAuraExpiration( "voidform", ExpireVoidform, buff.voidform.expires )
    end

    if IsActiveSpell( 356532 ) then
        applyBuff( "direct_mask", class.abilities.fae_guardians.lastCast + 20 - now )
    end

    -- If we are channeling Mind Sear, see if it started with Thought Harvester.
    local _, _, _, start, finish, _, _, spellID = UnitChannelInfo( "player" )

    if spellID == 48045 then
        start = start / 1000
        finish = finish / 1000

        if abs( start - thought_harvester_consumed ) < 0.1 then
            applyBuff( "mind_sear_th", finish - start )
            buff.mind_sear_th.applied = start
            buff.mind_sear_th.expires = finish
        else
            removeBuff( "mind_sear_th" )
        end

        if abs( start - mind_devourer_consumed ) < 0.1 then
            applyBuff( "mind_devourer_ms_active", finish - start )
            buff.mind_devourer_ms_active.applied = start
            buff.mind_devourer_ms_active.expires = finish
        else
            removeBuff( "mind_devourer_ms_active" )
        end
    else
        removeBuff( "mind_sear_th" )
    end

    if settings.pad_void_bolt and cooldown.void_bolt.remains > 0 then
        reduceCooldown( "void_bolt", latency * 2 )
    end

    if settings.pad_ascended_blast and cooldown.ascended_blast.remains > 0 then
        reduceCooldown( "ascended_blast", latency * 2 )
    end
end )


spec:RegisterHook( "pregain", function( amount, resource, overcap )
    if amount > 0 and resource == "insanity" and state.buff.memory_of_lucid_dreams.up then
        amount = amount * 2
    end

    return amount, resource, overcap
end )


spec:RegisterStateTable( "priest", {
    self_power_infusion = true
} )


-- Auras
spec:RegisterAuras( {
    angelic_feather = {
        id = 121557,
        duration = 5,
        max_stack = 1,
    },
    -- Talent: Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=390669
    apathy = {
        id = 390669,
        duration = 4,
        type = "Magic",
        max_stack = 1
    },
    blessed_recovery = {
        id = 390771,
        duration = 6,
        tick_time = 2,
        max_stack = 1,
    },
    -- Talent: Movement speed increased by $s1%.
    -- https://wowhead.com/beta/spell=65081
    body_and_soul = {
        id = 65081,
        duration = 3,
        type = "Magic",
        max_stack = 1,
    },
    -- Talent: Increases the damage of your next Mind Blast or Mind spike by $s1%.
    -- https://wowhead.com/beta/spell=391243
    coalescing_shadows_buff = {
        id = 391243,
        duration = 60,
        max_stack = 3,
        copy = "coalescing_shadows"
    },
    coalescing_shadows_dot_buff = {
        id = 391244,
        duration = 15,
        max_stack = 3,
        copy = "coalescing_shadows_dot"
    },
    -- Talent: Your non-periodic Shadow damage is increased by $w1%. $?s341240[Critical strike chance increased by ${$W4}.1%.][]
    -- https://wowhead.com/beta/spell=391109
    dark_ascension = {
        id = 391109,
        duration = 20,
        max_stack = 1
    },
    -- Talent: Periodic Shadow damage increased by $w1%.
    -- https://wowhead.com/beta/spell=391099
    dark_evangelism = {
        id = 391099,
        duration = 25,
        max_stack = 5
    },
    dark_thought = {
        id = 341207,
        duration = 10,
        max_stack = 1,
        copy = "dark_thoughts"
    },
    death_and_madness = {
        id = 321973,
        duration = 4,
        max_stack = 1,
    },
    death_and_madness_debuff = {
        id = 322098,
        duration = 7,
        max_stack = 1,
    },
    -- Talent: Next Shadow Word: Death deals full damage regardless of health.
    -- https://wowhead.com/beta/spell=392511
    deathspeaker = {
        id = 392511,
        duration = 15,
        max_stack = 1
    },
    -- Maximum health increased by $w1%.
    -- https://wowhead.com/beta/spell=19236
    desperate_prayer = {
        id = 19236,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Suffering $w2 damage every $t2 sec.
    -- https://wowhead.com/beta/spell=335467
    devouring_plague = {
        id = 335467,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Damage taken reduced by $s1%. Healing for $?s288733[${$s5+$288733s2}][$s5]% of maximum health.    Cannot attack or cast spells.    Movement speed increased by $s4% and immune to all movement impairing effects.
    -- https://wowhead.com/beta/spell=47585
    dispersion = {
        id = 47585,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- Healing received increased by $w2%.
    -- https://wowhead.com/beta/spell=64844
    divine_hymn = {
        id = 64844,
        duration = 15,
        type = "Magic",
        max_stack = 5
    },
    -- Talent: Under the control of the Priest.
    -- https://wowhead.com/beta/spell=205364
    dominate_mind = {
        id = 205364,
        duration = 30,
        mechanic = "charm",
        type = "Magic",
        max_stack = 1
    },
    echoing_void = {
        id = 373281,
        duration = 20,
        max_stack = 20
    },
    -- Reduced threat level. Enemies have a reduced attack range against you.$?e3  [   Damage taken reduced by $s4%.][]
    -- https://wowhead.com/beta/spell=586
    fade = {
        id = 586,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    -- Covenant: Damage taken reduced by $w2%.
    -- https://wowhead.com/beta/spell=324631
    fleshcraft = {
        id = 324631,
        duration = 3,
        tick_time = 0.5,
        max_stack = 1
    },
    -- All damage taken reduced by $w1%.
    -- https://wowhead.com/beta/spell=45242
    focused_will = {
        id = 45242,
        duration = 8,
        max_stack = 1
    },
    -- Talent: The healing of your next Flash Heal is increased by $w1%.
    -- https://wowhead.com/beta/spell=390617
    from_darkness_comes_light = {
        id = 390617,
        duration = 15,
        max_stack = 50
    },
    -- Talent: Conjuring $373273s1 Shadowy Apparitions will summon a Thing from Beyond.
    -- https://wowhead.com/beta/spell=373276
    idol_of_yoggsaron = {
        id = 373276,
        duration = 120,
        max_stack = 25
    },
    -- Talent: Reduces physical damage taken by $s1%.
    -- https://wowhead.com/beta/spell=390677
    inspiration = {
        id = 390677,
        duration = 15,
        max_stack = 1
    },
    -- Talent: Being pulled toward the Priest.
    -- https://wowhead.com/beta/spell=73325
    leap_of_faith = {
        id = 73325,
        duration = 1.5,
        mechanic = "grip",
        type = "Magic",
        max_stack = 1
    },
    levitate = {
        id = 111759,
        duration = 600,
        type = "Magic",
        max_stack = 1,
    },
    mental_fortitude = {
        id = 377066,
        duration = 15,
        max_stack = 1,
        copy = 194022
    },
    -- Talent: Under the command of the Priest.
    -- https://wowhead.com/beta/spell=605
    mind_control = {
        id = 605,
        duration = 30,
        mechanic = "charm",
        type = "Magic",
        max_stack = 1
    },
    mind_devourer = {
        id = 373204,
        duration = 15,
        max_stack = 1,
        copy = 338333
    },
    mind_devourer_ms_active = {
        duration = function () return 4.5 * haste end,
        max_stack = 1
    },
    -- Movement speed slowed by $s2% and taking Shadow damage every $t1 sec.
    -- https://wowhead.com/beta/spell=15407
    mind_flay = {
        id = 15407,
        duration = function () return 4.5 * haste end,
        tick_time = function () return 0.75 * haste end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Movement speed slowed by $s2% and taking Shadow damage every $t1 sec.
    -- https://wowhead.com/beta/spell=391403
    mind_flay_insanity = {
        id = 391401,
        duration = 10,
        max_stack = 1
    },
    mind_flay_insanity_dot = {
        id = 391403,
        duration = function () return 3 * haste end,
        tick_time = function () return 0.75 * haste end,
        type = "Magic",
        max_stack = 1,
    },
    -- Talent: The cast time of your next Mind Blast is reduced by $w1% and its critical strike chance is increased by $s2%.
    -- https://wowhead.com/beta/spell=391092
    mind_melt = {
        id = 391092,
        duration = 10,
        max_stack = 2
    },
    -- Talent: Causing Shadow damage to all targets within $49821a2 yards every $t1 sec.
    -- https://wowhead.com/beta/spell=48045
    mind_sear = {
        id = 48045,
        duration = 3,
        tick_time = 0.75,
        type = "Magic",
        max_stack = 1,
        copy = { 344754, 394976 }
    },
    mind_sear_th = {
        duration = function () return 4.5 * haste end,
        max_stack = 1,
    },
    -- Reduced distance at which target will attack.
    -- https://wowhead.com/beta/spell=453
    mind_soothe = {
        id = 453,
        duration = 20,
        type = "Magic",
        max_stack = 1
    },
    -- Sight granted through target's eyes.
    -- https://wowhead.com/beta/spell=2096
    mind_vision = {
        id = 2096,
        duration = 60,
        type = "Magic",
        max_stack = 1
    },
    mindbender = {
        duration = 15,
        max_stack = 1,
    },
    -- Talent / Covenant: The next $w2 damage and $w5 healing dealt will be reversed.
    -- https://wowhead.com/beta/spell=323673
    mindgames = {
        id = 375901,
        duration = function() return talent.shattered_perceptions.enabled and 7 or 5 end,
        type = "Magic",
        max_stack = 1,
        copy = 323673
    },
    -- Talent: Haste increased by $w1%.
    -- https://wowhead.com/beta/spell=10060
    power_infusion = {
        id = 10060,
        duration = 20,
        max_stack = 1
    },
    -- Stamina increased by $w1%.$?$w2>0[  Magic damage taken reduced by $w2%.][]
    -- https://wowhead.com/beta/spell=21562
    power_word_fortitude = {
        id = 21562,
        duration = 3600,
        type = "Magic",
        max_stack = 1,
        shared = "player", -- use anyone's buff on the player, not just player's.
    },
    -- Absorbs $w1 damage.
    -- https://wowhead.com/beta/spell=17
    power_word_shield = {
        id = 17,
        duration = 15,
        mechanic = "shield",
        type = "Magic",
        max_stack = 1
    },
    protective_light = {
        id = 193065,
        duration = 10,
        max_stack = 1,
    },
    -- Talent: Stunned.
    -- https://wowhead.com/beta/spell=64044
    psychic_horror = {
        id = 64044,
        duration = 4,
        mechanic = "stun",
        type = "Magic",
        max_stack = 1
    },
    -- Disoriented.
    -- https://wowhead.com/beta/spell=8122
    psychic_scream = {
        id = 8122,
        duration = 8,
        mechanic = "flee",
        type = "Magic",
        max_stack = 1
    },
    -- $w1 Radiant damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=204213
    purge_the_wicked = {
        id = 204213,
        duration = 20,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Healing $w1 health every $t1 sec.
    -- https://wowhead.com/beta/spell=139
    renew = {
        id = 139,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    rhapsody = {
        id = 390636,
        duration = 3600,
        max_stack = 20
    },
    -- Taking $s2% increased damage from the Priest.
    -- https://wowhead.com/beta/spell=214621
    schism = {
        id = 214621,
        duration = 9,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Shackled.
    -- https://wowhead.com/beta/spell=9484
    shackle_undead = {
        id = 9484,
        duration = 50,
        mechanic = "shackle",
        type = "Magic",
        max_stack = 1
    },
    shadow_crash_debuff = {
        id = 342385,
        duration = 15,
        max_stack = 2
    },
    -- Suffering $w2 Shadow damage every $t2 sec.
    -- https://wowhead.com/beta/spell=589
    shadow_word_pain = {
        id = 589,
        duration = function() return talent.misery.enabled and 21 or 16 end,
        type = "Magic",
        max_stack = 1,
        tick_time = function () return 2 * haste * ( 1 - 0.4 * ( ( debuff.mind_flay.up or debuff.mind_sear.up ) and talent.screams_of_the_void.rank or 0 ) ) end,
    },
    -- Talent: 343726
    -- https://wowhead.com/beta/spell=34433
    shadowfiend = {
        id = 34433,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Spell damage dealt increased by $s1%.
    -- https://wowhead.com/beta/spell=232698
    shadowform = {
        id = 232698,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    shadowy_apparitions = {
        id = 78203,
    },
    shadowy_insight = {
        id = 375981,
        duration = 10,
        max_stack = 1,
        copy = 124430
    },
    -- Talent: Silenced.
    -- https://wowhead.com/beta/spell=15487
    silence = {
        id = 15487,
        duration = 4,
        mechanic = "silence",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Your next Mind Spike is instant cast, and deals $s2% additional damage.
    -- https://wowhead.com/beta/spell=87160
    surge_of_darkness = {
        id = 87160,
        duration = 10,
        max_stack = 3
    },
    -- Taking Shadow damage every $t1 sec.
    -- https://wowhead.com/beta/spell=363656
    torment_mind = {
        id = 363656,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Increases damage and healing by $w1%.
    -- https://wowhead.com/beta/spell=390978
    twist_of_fate = {
        id = 390978,
        duration = 8,
        max_stack = 1
    },
    unfurling_darkness = {
        id = 341282,
        duration = 15,
        max_stack = 1,
    },
    unfurling_darkness_icd = {
        id = 341291,
        duration = 15,
        max_stack = 1
    },
    -- Suffering $w1 damage every $t1 sec. When damaged, the attacker is healed for $325118m1.
    -- https://wowhead.com/beta/spell=325203
    unholy_transfusion = {
        id = 325203,
        duration = 15,
        tick_time = 3,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: $15286s1% of any single-target Shadow spell damage you deal heals a nearby ally.
    -- https://wowhead.com/beta/spell=15286
    vampiric_embrace = {
        id = 15286,
        duration = 15,
        tick_time = 0.5,
        type = "Magic",
        max_stack = 1
    },
    -- Suffering $w2 Shadow damage every $t2 sec.
    -- https://wowhead.com/beta/spell=34914
    vampiric_touch = {
        id = 34914,
        duration = 21,
        tick_time = function () return 3 * haste * ( 1 - 0.4 * ( ( debuff.mind_flay.up or debuff.mind_sear.up ) and talent.screams_of_the_void.rank or 0 ) ) end,
        type = "Magic",
        max_stack = 1
    },
    void_bolt = {
        id = 228266,
    },
    -- Talent: A Shadowy tendril is appearing under you.
    -- https://wowhead.com/beta/spell=108920
    void_tendrils_root = {
        id = 108920,
        duration = 0.5,
        mechanic = "root",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Dealing $s1 Shadow damage to the target every $t1 sec.
    -- https://wowhead.com/beta/spell=263165
    void_torrent = {
        id = 263165,
        duration = 3,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: |cFFFFFFFFGenerates ${$s1*$s2/100} Insanity over $d.|r
    -- https://wowhead.com/beta/spell=289577
    void_torrent_insanity = {
        id = 289577,
        duration = 3,
        tick_time = 1,
        max_stack = 1
    },
    voidform = {
        id = 194249,
        duration = 15, -- function () return talent.legacy_of_the_void.enabled and 3600 or 15 end,
        max_stack = 1,
    },
    weakened_soul = {
        id = 6788,
        duration = function () return 7.5 * haste end,
        max_stack = 1,
    },
    -- Talent: Damage and healing of Smite and Holy Nova is increased by $s1%.
    -- https://wowhead.com/beta/spell=390933
    words_of_the_pious = {
        id = 390933,
        duration = 12,
        max_stack = 1
    },

    -- Azerite Powers
    chorus_of_insanity = {
        id = 279572,
        duration = 120,
        max_stack = 120,
    },
    death_denied = {
        id = 287723,
        duration = 10,
        max_stack = 1,
    },
    depth_of_the_shadows = {
        id = 275544,
        duration = 12,
        max_stack = 30
    },
    searing_dialogue = {
        id = 288371,
        duration = 1,
        max_stack = 1
    },
    thought_harvester = {
        id = 288343,
        duration = 20,
        max_stack = 1,
        copy = "harvested_thoughts" -- SimC uses this name (carryover from Legion?)
    },

    -- Legendaries (Shadowlands)
    measured_contemplation = {
        id = 341824,
        duration = 3600,
        max_stack = 4
    },
    shadow_word_manipulation = {
        id = 357028,
        duration = 10,
        max_stack = 1,
    },

    -- Conduits
    dissonant_echoes = {
        id = 343144,
        duration = 10,
        max_stack = 1,
    },
    lights_inspiration = {
        id = 337749,
        duration = 5,
        max_stack = 1
    },
    translucent_image = {
        id = 337661,
        duration = 5,
        max_stack = 1
    },
} )





-- Abilities
spec:RegisterAbilities( {
    -- Talent: Places a feather at the target location, granting the first ally to walk through it $121557s1% increased movement speed for $121557d. Only 3 feathers can be placed at one time.
    angelic_feather = {
        id = 121536,
        cast = 0,
        charges = 3,
        cooldown = 20,
        recharge = 20,
        gcd = "spell",
        school = "holy",

        talent = "angelic_feather",
        startsCombat = false,

        handler = function ()
        end,
    },

    -- Heals the target and ${$s2-1} injured allies within $A1 yards of the target for $s1.
    circle_of_healing = {
        id = 204883,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "holy",

        spend = 0.033,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
        end,
    },

    -- Talent: Instantly afflicts the target with Shadow Word: Pain, Vampiric Touch and Devouring Plague.
    damnation = {
        id = 341374,
        cast = 0,
        cooldown = function() return 60 - 15 * talent.malediction.rank end,
        gcd = "spell",
        school = "shadow",

        talent = "damnation",
        startsCombat = true,

        cycle = function()
            if debuff.devouring_plague.up then return "devouring_plague" end
            if debuff.vampiric_touch.up then return "vampiric_touch" end
            if debuff.shadow_word_pain.up then return "shadow_word_pain" end
        end,

        handler = function ()
            applyDebuff( "target", "shadow_word_pain" )
            applyDebuff( "target", "vampiric_touch" )
            applyDebuff( "target", "devouring_plague" )

            if talent.unfurling_darkness.enabled and debuff.unfurling_darkness_icd.down then
                applyBuff( "unfurling_darkness" )
                applyDebuff( "player", "unfurling_darkness_icd" )
            end
        end,
    },

    -- Talent: Increases your non-periodic Shadow damage by $s1% for 20 sec.    |cFFFFFFFFGenerates ${$m2/100} Insanity.|r
    dark_ascension = {
        id = 391109,
        cast = function ()
            if pvptalent.void_origins.enabled then return 0 end
            return 1.5 * haste
        end,
        cooldown = 60,
        gcd = "spell",
        school = "shadow",

        spend = -30,
        spendType = "insanity",

        talent = "dark_ascension",
        startsCombat = false,
        toggle = "cooldowns",

        handler = function ()
            applyBuff( "dark_ascension" )
        end,
    },

    -- Talent: Unleashes an explosion of dark energy around your target, dealing $s1 Shadow damage and applying Shadow Word: Pain to your target and ${$s2-1} nearby enemies.    |cFFFFFFFFGenerates ${$391450s1/100} Insanity.|r
    dark_void = {
        id = 263346,
        cast = 2,
        cooldown = 30,
        gcd = "spell",
        school = "shadow",

        spend = -15,
        spendType = "insanity",

        talent = "dark_void",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "shadow_word_pain" )
            active_dot.shadow_word_pain = min( true_active_enemies, active_dot.shadow_word_pain + 15 )
        end,
    },

    -- Increases maximum health by $?s373450[${$s1+$373450s1}][$s1]% for $d, and instantly heals you for that amount.
    desperate_prayer = {
        id = 19236,
        cast = 0,
        cooldown = 90,
        gcd = "off",
        school = "holy",

        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "desperate_prayer" )
            health.max = health.max * 1.25
            gain( 0.8 * health.max, "health" )
            if conduit.lights_inspiration.enabled then applyBuff( "lights_inspiration" ) end
        end,
    },

    -- Talent: Afflicts the target with a disease that instantly causes $s1 Shadow damage plus an additional $o2 Shadow damage over $d. Heals you for ${$e2*100}% of damage dealt.    If this effect is reapplied, any remaining damage will be added to the new Devouring Plague.
    devouring_plague = {
        id = 335467,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = function () return buff.mind_devourer.up and 0 or 50 end,
        spendType = "insanity",

        talent = "devouring_plague",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "devouring_plague" )

            removeBuff( "mind_devourer" )
            removeBuff( "gathering_shadows" )

            if talent.mind_flay_insanity.enabled then applyBuff( "mind_flay_insanity" ) end

            if set_bonus.tier29_4pc > 0 then applyBuff( "dark_reveries" ) end
        end,
    },

    -- Talent: Dispels Magic on the enemy target, removing $m1 beneficial Magic $leffect:effects;.
    dispel_magic = {
        id = 528,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = function () return 0.02 * ( 1 + conduit.clear_mind.mod * 0.01 ) end,
        spendType = "mana",

        talent = "dispel_magic",
        startsCombat = false,

        buff = "dispellable_magic",
        handler = function ()
            removeBuff( "dispellable_magic" )
        end,
    },

    -- Talent: Disperse into pure shadow energy, reducing all damage taken by $s1% for $d and healing you for $?s288733[${$s5+$288733s2}][$s5]% of your maximum health over its duration, but you are unable to attack or cast spells.    Increases movement speed by $s4% and makes you immune to all movement impairing effects.    Castable while stunned, feared, or silenced.
    dispersion = {
        id = 47585,
        cast = 0,
        cooldown = function () return talent.intangibility.enabled and 90 or 120 end,
        gcd = "spell",
        school = "shadow",

        talent = "dispersion",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "dispersion" )
            setCooldown( "global_cooldown", 6 )
        end,
    },

    -- Talent: Throw a Divine Star forward 24 yds, healing allies in its path for $110745s1 and dealing $122128s1 Shadow damage to enemies. After reaching its destination, the Divine Star returns to you, healing allies and damaging enemies in its path again. Healing reduced beyond $s1 targets.
    divine_star = {
        id = 122121,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "shadow",

        spend = 0.005,
        spendType = "mana",

        talent = "divine_star",
        startsCombat = true,

        handler = function ()
            gain( 6, "insanity" )
        end,
    },

    -- Talent: Controls a mind up to 1 level above yours for $d while still controlling your own mind. Does not work versus Demonic, Mechanical, or Undead beings$?a205477[][ or players]. This spell shares diminishing returns with other disorienting effects.
    dominate_mind = {
        id = 205364,
        cast = 1.8,
        cooldown = 30,
        gcd = "spell",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        talent = "dominate_mind",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "dominate_mind" )
        end,
    },

    -- Fade out, removing all your threat and reducing enemies' attack range against you for $d.
    fade = {
        id = 586,
        cast = 0,
        cooldown = function() return 30 - 5 * talent.improved_fade.rank end,
        gcd = "off",
        school = "shadow",

        startsCombat = false,

        handler = function ()
            applyBuff( "fade" )
            if conduit.translucent_image.enabled then applyBuff( "translucent_image" ) end
        end,
    },

    -- A fast spell that heals an ally for $s1.
    flash_heal = {
        id = 2061,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = function() return buff.surge_of_light.up and 0 or 0.036 end,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            removeBuff( "from_darkness_comes_light" )
            removeStack( "surge_of_light" )
            if talent.protective_light.enabled then applyBuff( "protective_light" ) end
        end,
    },

    -- Talent: Creates a ring of Shadow energy around you that quickly expands to a 30 yd radius, healing allies for $120692s1 and dealing $120696s1 Shadow damage to enemies.    Healing reduced beyond $s1 targets.
    halo = {
        id = 120644,
        cast = 1.5,
        cooldown = 40,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        talent = "halo",
        startsCombat = true,

        handler = function ()
            gain( 10, "insanity" )
        end,
    },

    -- Talent: An explosion of holy light around you deals up to $s1 Holy damage to enemies and up to $281265s1 healing to allies within $A1 yds, reduced if there are more than $s3 targets.
    holy_nova = {
        id = 132157,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = 0.016,
        spendType = "mana",

        talent = "holy_nova",
        startsCombat = true,

        handler = function ()
        end,
    },

    -- Talent: Pulls the spirit of a party or raid member, instantly moving them directly in front of you.
    leap_of_faith = {
        id = 73325,
        cast = 0,
        charges = function () return legendary.vault_of_heavens.enabled and 2 or nil end,
        cooldown = function() return talent.move_with_grace.enabled and 60 or 90 end,
        recharge = function () return legendary.vault_of_heavens.enabled and ( talent.move_with_grace.enabled and 60 or 90 ) or nil end,
        gcd = "off",
        school = "holy",

        spend = 0.026,
        spendType = "mana",

        talent = "leap_of_faith",
        startsCombat = false,
        toggle = "interrupts",

        usable = function() return group, "requires an ally" end,
        handler = function ()
            if talent.body_and_soul.enabled then applyBuff( "body_and_soul" ) end
            if azerite.death_denied.enabled then applyBuff( "death_denied" ) end
            if legendary.vault_of_heavens.enabled then setDistance( 5 ) end
        end,
    },

    --[[  Talent: You pull your spirit to an ally, instantly moving you directly in front of them.
    leap_of_faith = {
        id = 336471,
        cast = 0,
        charges = 2,
        cooldown = 1.5,
        recharge = 90,
        gcd = "off",
        school = "holy",

        talent = "leap_of_faith",
        startsCombat = false,

        handler = function ()
        end,
    }, ]]

    -- Levitates a party or raid member for $111759d, floating a few feet above the ground, granting slow fall, and allowing travel over water.
    levitate = {
        id = 1706,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = 0.009,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyBuff( "levitate" )
        end,
    },

    --[[ Invoke the Light's wrath, dealing $s1 Radiant damage to the target, increased by $s2% per ally affected by your Atonement.
    lights_wrath = {
        id = 373178,
        cast = 2.5,
        cooldown = 90,
        gcd = "spell",
        school = "holyfire",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
        end,
    }, ]]

    -- Talent: Dispels magic in a $32375a1 yard radius, removing all harmful Magic from $s4 friendly targets and $32592m1 beneficial Magic $leffect:effects; from $s4 enemy targets. Potent enough to remove Magic that is normally undispellable.
    mass_dispel = {
        id = 32375,
        cast = function () return pvptalent.improved_mass_dispel.enabled and 0.5 or 1.5 end,
        cooldown = function () return pvptalent.improved_mass_dispel.enabled and 25 or 45 end,
        gcd = "spell",
        school = "holy",

        spend = 0.08,
        spendType = "mana",

        talent = "mass_dispel",
        startsCombat = false,

        usable = function () return buff.dispellable_magic.up or debuff.dispellable_magic.up end,
        handler = function ()
            removeBuff( "dispellable_magic" )
            removeDebuff( "player", "dispellable_magic" )
            if time > 0 then gain( 6, "insanity" ) end
        end,
    },

    -- Blasts the target's mind for $s1 Shadow damage.$?s137033[    |cFFFFFFFFGenerates $/100;s2 Insanity|r][]$?s391137[ |cFFFFFFFFand an additional ${$s3/100} Insanity from a critical strike.|r][.]
    mind_blast = {
        id = 8092,
        cast = function () return buff.shadowy_insight.up and 0 or ( ( 1.5 * haste ) * ( 1 - 0.5 * buff.mind_melt.stack ) ) end,
        charges = function ()
            if not talent.shadowy_insight.enabled then return end
            return 2
        end,
        cooldown = 9,
        recharge = function ()
            if not talent.shadowy_insight.enabled then return end
            return 9 * haste
        end,
        hasteCD = true,
        gcd = "spell",
        school = "shadow",

        spend = -6,
        spendType = "insanity",

        startsCombat = true,
        velocity = 15,

        handler = function ()
            gain( 6, "insanity" )

            if buff.coalescing_shadows.up then
                applyBuff( "coalescing_shadows_dot" )
                removeBuff( "coalescing_shadows" )
            end

            removeBuff( "empty_mind" )
            removeBuff( "harvested_thoughts" )
            removeBuff( "mind_melt" )
            removeBuff( "shadowy_insight" )

            if talent.inescapable_torment.enabled then
                if buff.mindbender.up then buff.mindbender.expires = buff.mindbender.expires + talent.inescapable_torment.rank
                elseif buff.shadowfiend.up then buff.shadowfiend.expires = buff.shadowfiend.expires + talent.inescapable_torment.rank end
            end

            if talent.manipulation.enabled then
                reduceCooldown( "mindgames", 0.5 * talent.manipulation.rank )
            end

            if set_bonus.tier29_2pc > 0 then
                addStack( "gathering_shadows" )
            end
        end,
    },

    -- Talent: Controls a mind up to 1 level above yours for $d. Does not work versus Demonic$?A320889[][, Undead,] or Mechanical beings. Shares diminishing returns with other disorienting effects.
    mind_control = {
        id = 605,
        cast = 1.8,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        talent = "mind_control",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "mind_control" )
        end,
    },

    -- Assaults the target's mind with Shadow energy, causing $o1 Shadow damage over $d and slowing their movement speed by $s2%.    |cFFFFFFFFGenerates ${$s4*$s3/100} Insanity over the duration.|r
    mind_flay = {
        id = function() return buff.mind_flay_insanity.up and 391403 or 15407 end,
        known = 15407,
        cast = function() return ( buff.mind_flay_insanity.up and 3 or 4.5 ) * haste end,
        channeled = true,
        breakable = true,
        cooldown = 0,
        hasteCD = true,
        gcd = "spell",
        school = "shadow",

        spend = 0,
        spendType = "insanity",

        startsCombat = true,
        texture = function()
            if buff.mind_flay_insanity.up then return 425954 end
            return 136208
        end,
        nobuff = "boon_of_the_ascended",
        bind = "ascended_blast",

        aura = function() return buff.mind_flay_insanity.up and "mind_flay_insanity" or "mind_flay" end,
        tick_time = function () return class.auras.mind_flay.tick_time end,

        start = function ()
            if buff.mind_flay_insanity.up then
                removeBuff( "mind_flay_insanity" )
                applyDebuff( "target", "mind_flay_insanity_dot" )
            else
                applyDebuff( "target", "mind_flay" )
            end
            if talent.dark_evangelism.enabled then addStack( "dark_evangelism" ) end
            if talent.manipulation.enabled then reduceCooldown( "mindgames", 0.5 * talent.manipulation.rank ) end
        end,

        tick = function ()
            if talent.dark_evangelism.enabled then addStack( "dark_evangelism" ) end
            if talent.mental_decay.enabled then
                if debuff.shadow_word_pain.up then debuff.shadow_word_pain.expires = debuff.shadow_word_pain.expires + 1 end
                if debuff.vampiric_touch.up then debuff.vampiric_touch.expires = debuff.vampiric_touch.expires + 1 end
            end
        end,

        breakchannel = function ()
            removeDebuff( "target", "mind_flay" )
            removeDebuff( "target", "mind_flay_insanity_dot" )
        end,

        copy = { "mind_flay_insanity", 391403 }
    },

    -- Talent: |cFFFFFFFF$s3 Insanity, plus $s3 every ${$t1}.1 sec  Channeled|r  Corrosive shadow energy radiates from the target, dealing ${$49821s2*$s2} Shadow damage over $48045d to all enemies within $49821a2 yards of the target.
    mind_sear = {
        id = 48045,
        cast = 4.5,
        channeled = true,
        breakable = true,
        prechannel = true,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = function() return buff.mind_devourer.up and 0 or 25 end,
        spendType = "insanity",

        talent = "mind_sear",
        startsCombat = true,

        aura = "mind_sear",
        tick_time = function () return class.auras.mind_flay.tick_time end,
        readyTime = function() return settings.min_sear_ticks > 0 and buff.mind_devourer.down and insanity[ "time_to_" .. ( 25 * settings.min_sear_ticks ) ] or 0 end,

        start = function ()
            applyDebuff( "target", "mind_sear" )
            channelSpell( "mind_sear" )

            removeBuff( "mind_devourer" )
            removeBuff( "gathering_shadows" )

            if buff.thought_harvester.up then
                removeBuff( "thought_harvester" )
                applyBuff( "mind_sear_th" )
            end

            if buff.mind_devourer.up then
                removeBuff( "mind_devourer" )
                applyBuff( "mind_devourer_ms_active" )
            end

            if talent.dark_evangelism.enabled then addStack( "dark_evangelism" ) end

            if azerite.searing_dialogue.enabled then applyDebuff( "target", "searing_dialogue" ) end

            if set_bonus.tier29_4pc > 0 then applyBuff( "dark_reveries" ) end

            forecastResources( "insanity" )
        end,

        tick = function()
            if talent.dark_evangelism.enabled then addStack( "dark_evangelism" ) end
            if talent.mental_decay.enabled then
                if debuff.shadow_word_pain.up then debuff.shadow_word_pain.expires = debuff.shadow_word_pain.expires + 1 end
                if debuff.vampiric_touch.up then debuff.vampiric_touch.expires = debuff.vampiric_touch.expires + 1 end
            end
        end,

        breakchannel = function ()
            removeDebuff( "target", "mind_sear" )
            removeBuff( "mind_sear_th" )
            removeBuff( "mind_devourer_ms_active" )
        end,
    },

    -- Soothes enemies in the target area, reducing the range at which they will attack you by $s1 yards. Only affects Humanoid and Dragonkin targets. Does not cause threat. Lasts $d.
    mind_soothe = {
        id = 453,
        cast = 0,
        cooldown = 5,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "mind_soothe" )
        end,
    },

    -- Talent: Blasts the target for $s1 Shadowfrost damage.$?s391090[    Mind Spike reduces the cast time of your next Mind Blast by $391092s1% and increases its critical strike chance by $391092s2%, stacking up to $391092U times.][]    |cFFFFFFFFGenerates ${$s2/100} Insanity|r$?s391137[ |cFFFFFFFFand an additional ${$s3/100} Insanity from a critical strike.|r][.]
    mind_spike = {
        id = 73510,
        cast = function() return buff.surge_of_darkness.up and 0 or 1.5 end,
        cooldown = 0,
        gcd = "spell",
        school = "shadowfrost",

        spend = -4,
        spendType = "insanity",

        talent = "mind_spike",
        startsCombat = true,

        handler = function ()
            removeStack( "surge_of_darkness" )

            if buff.coalescing_shadows.up then
                applyBuff( "coalescing_shadows_dot" )
                removeBuff( "coalescing_shadows" )
            end

            if talent.manipulation.enabled then
                reduceCooldown( "mindgames", 0.5 * talent.manipulation.rank )
            end

            if talent.mind_melt.enabled then addStack( "mind_melt" ) end
        end,
    },

    -- Allows the caster to see through the target's eyes for $d. Will not work if the target is in another instance or on another continent.
    mind_vision = {
        id = 2096,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "mind_vision" )
        end,
    },

    -- Talent: Summons a Mindbender to attack the target for $d.     |cFFFFFFFFGenerates ${$123051m1/100}.1% mana each time the Mindbender attacks.|r
    mindbender = {
        id = function () return talent.mindbender.enabled and 200174 or 34433 end,
        cast = 0,
        cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( talent.mindbender.enabled and 60 or 180 ) end,
        gcd = "spell",
        school = "shadow",

        startsCombat = true,
        toggle = function () return not talent.mindbender.enabled and "cooldowns" or nil end,

        handler = function ()
            summonPet( talent.mindbender.enabled and "mindbender" or "shadowfiend", 15 )
            applyBuff( talent.mindbender.enabled and "mindbender" or "shadowfiend" )
        end,

        copy = { "shadowfiend", 200174, 34433, 132603 }
    },

    -- Covenant (Venthyr): Assault an enemy's mind, dealing ${$s1*$m3/100} Shadow damage and briefly reversing their perception of reality.    $?c3[For $d, the next $<damage> damage they deal will heal their target, and the next $<healing> healing they deal will damage their target.    |cFFFFFFFFReversed damage and healing generate up to ${$323706s2*2} Insanity.|r]  ][For $d, the next $<damage> damage they deal will heal their target, and the next $<healing> healing they deal will damage their target.    |cFFFFFFFFReversed damage and healing restore up to ${$323706s3*2}% mana.|r]
    mindgames = {
        id = function() return talent.mindgames.enabled and 375901 or 323673 end,
        cast = 1.5,
        cooldown = 45,
        gcd = "spell",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "mindgames" )
            gain( 10, "insanity" )
        end,

        copy = { 375901, 323673 }
    },

    -- Talent: Infuses the target with power for $d, increasing haste by $s1%.
    power_infusion = {
        id = 10060,
        cast = 0,
        cooldown = function () return 120 - ( conduit.power_unto_others.mod and group and conduit.power_unto_others.mod or 0 ) end,
        gcd = "off",
        school = "holy",

        talent = "power_infusion",
        startsCombat = false,

        toggle = "cooldowns",
        indicator = function () return group and ( talent.twins_of_the_sun_priestess.enabled or legendary.twins_of_the_sun_priestess.enabled ) and "cycle" or nil end,

        handler = function ()
            applyBuff( "power_infusion" )
            stat.haste = stat.haste + 0.25
        end,
    },

    -- Infuses the target with vitality, increasing their Stamina by $s1% for $d.    If the target is in your party or raid, all party and raid members will be affected.
    power_word_fortitude = {
        id = 21562,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        nobuff = "power_word_fortitude",

        handler = function ()
            applyBuff( "power_word_fortitude" )
        end,
    },

    -- Talent: A word of holy power that heals the target for $s1. If the target is below $s2% health, Power Word: Life heals for $s3% more and the cooldown of Power Word: Life is reduced by $s4 sec.
    power_word_life = {
        id = 373481,
        cast = 0,
        cooldown = function() return health.pct < 35 and 20 or 30 end,
        gcd = "spell",
        school = "holy",

        spend = 0.005,
        spendType = "mana",

        talent = "power_word_life",
        startsCombat = false,

        handler = function ()
        end,
    },

    -- Shields an ally for $d, absorbing $<shield> damage.
    power_word_shield = {
        id = 17,
        cast = 0,
        cooldown = function() return buff.rapture.up and 0 or ( 7.5 * haste ) end,
        gcd = "spell",
        school = "holy",

        spend = 0.031,
        spendType = "mana",

        startsCombat = false,
        nodebuff = "weakened_soul",

        handler = function ()
            applyBuff( "power_word_shield" )
            applyDebuff( "player", "weakened_soul" )
            if talent.body_and_soul.enabled then applyBuff( "body_and_soul" ) end
            -- if time > 0 then gain( 6, "insanity" ) end
        end,
    },

    -- Talent: Places a ward on an ally that heals them for $33110s1 the next time they take damage, and then jumps to another ally within $155793a1 yds. Jumps up to $s1 times and lasts $41635d after each jump.
    prayer_of_mending = {
        id = 33076,
        cast = 0,
        cooldown = 12,
        hasteCD = true,
        gcd = "spell",
        school = "holy",

        spend = 0.02,
        spendType = "mana",

        talent = "prayer_of_mending",
        startsCombat = false,

        handler = function ()
            applyBuff( "prayer_of_mending" )
        end,
    },

    -- Talent: Terrifies the target in place, stunning them for $d.
    psychic_horror = {
        id = 64044,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "shadow",

        talent = "psychic_horror",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "psychic_horror" )
        end,
    },

    -- Lets out a psychic scream, causing $i enemies within $A1 yards to flee, disorienting them for $d. Damage may interrupt the effect.
    psychic_scream = {
        id = 8122,
        cast = 0,
        cooldown = function() return talent.psychic_void.enabled and 30 or 45 end,
        gcd = "spell",
        school = "shadow",

        spend = 0.012,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            if target.within8 then applyDebuff( "target", "psychic_scream" ) end
        end,
    },

    -- Talent: Removes all Disease effects from a friendly target.
    purify_disease = {
        id = 213634,
        cast = 0,
        charges = 1,
        cooldown = 8,
        recharge = 8,
        gcd = "spell",
        school = "holy",

        spend = 0.013,
        spendType = "mana",

        talent = "purify_disease",
        startsCombat = false,
        buff = "dispellable_disease",

        handler = function ()
            removeBuff( "dispellable_disease" )
            -- if time > 0 then gain( 6, "insanity" ) end
        end,
    },

    -- Talent: Fill the target with faith in the light, healing for $o1 over $d.
    renew = {
        id = 139,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = 0.018,
        spendType = "mana",

        talent = "renew",
        startsCombat = false,

        handler = function ()
            applyBuff( "renew" )
        end,
    },

    -- Talent: Shackles the target undead enemy for $d, preventing all actions and movement. Damage will cancel the effect. Limit 1.
    shackle_undead = {
        id = 9484,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = 0.012,
        spendType = "mana",

        talent = "shackle_undead",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "shackle_undead" )
        end,
    },

    -- Talent: Hurl a bolt of slow-moving Shadow energy at the destination, dealing $205386s1 Shadow damage to all targets within $205386A1 yards and applying Vampiric Touch to $391286s1 of them.    |cFFFFFFFFGenerates $/100;s2 Insanity.|r
    shadow_crash = {
        id = 205385,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "shadow",

        spend = -15,
        spendType = "insanity",

        talent = "shadow_crash",
        startsCombat = false,

        velocity = 2,

        impact = function ()
            applyDebuff( "target", "vampiric_touch" )
        end,
    },

    -- Talent: A word of dark binding that inflicts $s1 Shadow damage to the target. If the target is not killed by Shadow Word: Death, the caster takes damage equal to the damage inflicted upon the target.    $?A364675[Damage increased by ${$s3+$364675s2}% to targets below ${$s2+$364675s1}% health.][Damage increased by $s3% to targets below $s2% health.]$?c3[][]
    shadow_word_death = {
        id = 32379,
        cast = 0,
        charges = 1,
        cooldown = 20,
        recharge = 20,
        gcd = "spell",
        school = "shadow",

        spend = 0.005,
        spendType = "mana",

        talent = "shadow_word_death",
        startsCombat = true,

        usable = function ()
            if settings.sw_death_protection == 0 then return true end
            return health.percent >= settings.sw_death_protection, "health percent [ " .. health.percent .. " ] is below user setting [ " .. settings.sw_death_protection .. " ]"
        end,

        handler = function ()
            removeBuff( "deathspeaker" )
            removeBuff( "zeks_exterminatus" )

            if talent.death_and_madness.enabled then
                applyDebuff( "target", "death_and_madness_debuff" )
            end

            if talent.inescapable_torment.enabled then
                if buff.mindbender.up then buff.mindbender.expires = buff.mindbender.expires + talent.inescapable_torment.rank
                elseif buff.shadowfiend.up then buff.shadowfiend.expires = buff.shadowfiend.expires + talent.inescapable_torment.rank end
            end

            if legendary.painbreaker_psalm.enabled then
                local power = 0
                if debuff.shadow_word_pain.up then
                    power = power + 15 * min( debuff.shadow_word_pain.remains, 8 ) / 8
                    if debuff.shadow_word_pain.remains < 8 then removeDebuff( "shadow_word_pain" )
                    else debuff.shadow_word_pain.expires = debuff.shadow_word_pain.expires - 8 end
                end
                if debuff.vampiric_touch.up then
                    power = power + 15 * min( debuff.vampiric_touch.remains, 8 ) / 8
                    if debuff.vampiric_touch.remains <= 8 then removeDebuff( "vampiric_touch" )
                    else debuff.vampiric_touch.expires = debuff.vampiric_touch.expires - 8 end
                end
                if power > 0 then gain( power, "insanity" ) end
            end

            if legendary.shadowflame_prism.enabled then
                if pet.fiend.active then pet.fiend.expires = pet.fiend.expires + 1 end
            end
        end,
    },

    -- A word of darkness that causes $?a390707[${$s1*(1+$390707s1/100)}][$s1] Shadow damage instantly, and an additional $?a390707[${$o2*(1+$390707s1/100)}][$o2] Shadow damage over $d.$?s137033[    |cFFFFFFFFGenerates ${$m3/100} Insanity.|r][]
    shadow_word_pain = {
        id = 589,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = -3,
        spendType = "insanity",

        startsCombat = true,
        cycle = "shadow_word_pain",

        handler = function ()
            applyDebuff( "target", "shadow_word_pain" )
        end,
    },

    -- Assume a Shadowform, increasing your spell damage dealt by $s1%.
    shadowform = {
        id = 232698,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        startsCombat = false,
        essential = true,
        nobuff = function () return buff.voidform.up and "voidform" or "shadowform" end,

        handler = function ()
            applyBuff( "shadowform" )
        end,
    },

    -- Talent: Silences the target, preventing them from casting spells for $d. Against non-players, also interrupts spellcasting and prevents any spell in that school from being cast for $263715d.
    silence = {
        id = 15487,
        cast = 0,
        cooldown = function() return talent.last_word.enabled and 30 or 45 end,
        gcd = "off",
        school = "shadow",

        talent = "silence",
        startsCombat = true,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
            applyDebuff( "target", "silence" )
        end,
    },

    -- Talent: Fills you with the embrace of Shadow energy for $d, causing you to heal a nearby ally for $s1% of any single-target Shadow spell damage you deal.
    vampiric_embrace = {
        id = 15286,
        cast = 0,
        cooldown = function() return talent.sanlayn.enabled and 75 or 120 end,
        gcd = "off",
        school = "shadow",

        talent = "vampiric_embrace",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "vampiric_embrace" )
            -- if time > 0 then gain( 6, "insanity" ) end
        end,
    },

    -- A touch of darkness that causes $34914o2 Shadow damage over $34914d, and heals you for ${$e2*100}% of damage dealt. If Vampiric Touch is dispelled, the dispeller flees in Horror for $87204d.    |cFFFFFFFFGenerates ${$m3/100} Insanity.|r
    vampiric_touch = {
        id = 34914,
        cast = function () return buff.unfurling_darkness.up and 0 or 1.5 * haste end,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = -4,
        spendType = "insanity",

        startsCombat = true,
        cycle = function () return talent.misery.enabled and "shadow_word_pain" or "vampiric_touch" end,

        handler = function ()
            applyDebuff( "target", "vampiric_touch" )

            if talent.misery.enabled then
                applyDebuff( "target", "shadow_word_pain" )
            end

            if talent.unfurling_darkness.enabled then
                if buff.unfurling_darkness.up then
                    removeBuff( "unfurling_darkness" )
                elseif debuff.unfurling_darkness_icd.down then
                    applyBuff( "unfurling_darkness" )
                    applyDebuff( "player", "unfurling_darkness_icd" )
                end
            end
        end,
    },

    -- Sends a bolt of pure void energy at the enemy, causing $s2 Shadow damage$?s193225[, refreshing the duration of Devouring Plague on the target][]$?a231688[ and extending the duration of Shadow Word: Pain and Vampiric Touch on all nearby targets by $<ext> sec][].     Requires Voidform.    |cFFFFFFFFGenerates $/100;s3 Insanity.|r
    void_bolt = {
        id = 205448,
        known = 228260,
        cast = 0,
        cooldown = 6,
        hasteCD = true,
        gcd = "spell",
        school = "shadow",

        spend = -12,
        spendType = "insanity",

        startsCombat = true,
        velocity = 40,
        buff = function () return buff.dissonant_echoes.up and "dissonant_echoes" or "voidform" end,
        bind = "void_eruption",

        handler = function ()
            removeBuff( "dissonant_echoes" )

            if debuff.shadow_word_pain.up then debuff.shadow_word_pain.expires = debuff.shadow_word_pain.expires + 3 end
            if debuff.vampiric_touch.up then debuff.vampiric_touch.expires = debuff.vampiric_touch.expires + 3 end
            if talent.legacy_of_the_void.enabled and debuff.devouring_plague.up then debuff.devouring_plague.expires = query_time + debuff.devouring_plague.duration end

            removeBuff( "anunds_last_breath" )
        end,

        impact = function ()
        end,

        copy = 343355,
    },

    -- Talent: Releases an explosive blast of pure void energy, activating Voidform and causing ${$228360s1*2} Shadow damage to all enemies within $a1 yds of your target.    During Voidform, this ability is replaced by Void Bolt.    Each $s4 Insanity spent during Voidform increases the duration of Voidform by ${$s3/1000}.1 sec.
    void_eruption = {
        id = 228260,
        cast = function ()
            if pvptalent.void_origins.enabled then return 0 end
            return haste * 1.5
        end,
        cooldown = 120,
        gcd = "spell",
        school = "shadow",

        talent = "void_eruption",
        startsCombat = true,
        toggle = "cooldowns",
        nobuff = function () return buff.dissonant_echoes.up and "dissonant_echoes" or "voidform" end,
        bind = "void_bolt",

        cooldown_ready = function ()
            return cooldown.void_eruption.remains == 0 and buff.voidform.down
        end,

        handler = function ()
            applyBuff( "voidform" )
        end,
    },

    -- Talent: You and the currently targeted party or raid member swap health percentages. Increases the lower health percentage of the two to $s1% if below that amount.
    void_shift = {
        id = 108968,
        cast = 0,
        cooldown = 300,
        gcd = "off",
        school = "shadow",

        talent = "void_shift",
        startsCombat = false,

        toggle = "defensives",
        usable = function() return group, "requires an ally" end,

        handler = function ()
        end,
    },

    -- Talent: Summons shadowy tendrils, rooting up to $108920i enemy targets within $108920A1 yards for $114404d or until the tendril is killed.
    void_tendrils = {
        id = 108920,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        talent = "void_tendrils",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "void_tendrils_root" )
        end,
    },

    -- Talent: Channel a torrent of void energy into the target, dealing $o Shadow damage over $d.    |cFFFFFFFFGenerates ${$289577s1*$289577s2/100} Insanity over the duration.|r
    void_torrent = {
        id = 263165,
        cast = 3,
        channeled = true,
        fixedCast = true,
        cooldown = function() return 60 - 15 * talent.malediction.rank end,
        gcd = "spell",
        school = "shadow",

        spend = -15,
        spendType = "insanity",

        talent = "void_torrent",
        startsCombat = true,
        aura = "void_torrent",
        tick_time = function () return class.auras.void_torrent.tick_time end,

        breakchannel = function ()
            removeDebuff( "target", "void_torrent" )
        end,

        start = function ()
            applyDebuff( "target", "void_torrent" )
            applyDebuff( "target", "devouring_plague" )
            if debuff.vampiric_touch.up then applyDebuff( "target", "vampiric_touch" ) end -- This should refresh/pandemic properly.
            if debuff.shadow_word_pain.up then applyDebuff( "target", "shadow_word_pain" ) end -- This should refresh/pandemic properly.
            if talent.dark_evangelism.enabled then addStack( "dark_evangelism" ) end
        end,

        tick = function ()
            if debuff.vampiric_touch.up then applyDebuff( "target", "vampiric_touch" ) end -- This should refresh/pandemic properly.
            if debuff.shadow_word_pain.up then applyDebuff( "target", "shadow_word_pain" ) end -- This should refresh/pandemic properly.
            if talent.dark_evangelism.enabled then addStack( "dark_evangelism" ) end
        end,
    },
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    nameplates = false,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 6,

    potion = "potion_of_spectral_intellect",

    package = "Shadow",
} )


spec:RegisterSetting( "pad_void_bolt", true, {
    name = "Pad |T1035040:0|t Void Bolt Cooldown",
    desc = "If checked, the addon will treat |T1035040:0|t Void Bolt's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during Voidform.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "pad_ascended_blast", true, {
    name = "Pad |T3528286:0|t Ascended Blast Cooldown",
    desc = "If checked, the addon will treat |T3528286:0|t Ascended Blast's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during Boon of the Ascended.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "sw_death_protection", 50, {
    name = "|T136149:0|t Shadow Word: Death Health Threshold",
    desc = "If set above 0, the addon will not recommend |T136149:0|t Shadow Word: Death while your health percentage is below this threshold.  This setting can help keep you from killing yourself.",
    type = "range",
    min = 0,
    max = 100,
    step = 0.1,
    width = "full",
} )

spec:RegisterSetting( "min_sear_ticks", 2, {
    name = "|T237565:0|t Mind Sear Ticks",
    desc = "|T237565:0|t Mind Sear costs 25 Insanity (and 25 additional Insanity per tick).  If set above 0, this setting will treat Mind Sear as unusable if your cast would result in fewer ticks of Mind Sear than desired.",
    type = "range",
    min = 0,
    max = 4,
    step = 1,
    width = "full",
} )


spec:RegisterPack( "Shadow", 20230330, [[Hekili:T31EVTnss(plgdwgPyhf9Wk2zGLwm7K9UBgSZmbRZndU)Xu0uuwCTePoskNyad9z)QQBs2VQUjLSCWM9wGDd8i2S7QQU66XVQAPBgCZNU565bfr38Rd7pCu)rJ63BW4bVV)GBUU4Xnr3C9MGW7dUd(JKG1W)E9YG5PFg)4hxLgmhF980TzHWJwwuSj)7F7BVlUy52B7fMU(T5XR3UkOionjmlyrb(Fh(2BU(2TXRk(PKBULATV883FZ1bBlwMMblx86FeM545ZJ4dpkp8MRXH)M(W)B83VB2Uz)XYOKDZ4u2Uz)ywq(YDZIZH)FYBwSk(ULfNTBwqyb8pWhct827GbC9F8r4dsMVB2V)j4pYIG)zvwuW8hH)yZMvXrWJks3n7rG)G)ki7UOIE7(5D)C1YpyeB5)7PBlItGxF7gKB2nBrw6Ay(bsxz4dFpB4)sW9WyE1Y0vZJtUZpej3xTB2dbzXb3UcEur2w4FJxWw5x9a83ZJZXhnxJjvM9r9zZ(hstEfWOHpgUkYNtZapVif4GFjgz2RJcY6DZ1RIZlYXDVfXRwfLb)1VY0fIsyR0n)LBUomlUicikC)AXIERHx3FXQGh9JtYdsIlES32n7M5bKxArVhcwVjolo0ViDB4YEfXH3dCx9JZz0T)NtZM7VjiorzaD2n7KDZyls(wGI9tx4ppi7(KO8C2A80tO8FvucmrHWw06CCiflJ8FinEEVsAE3SUGItiQTDZ11u7nfG6LgNvnivIwMJZIwKfbenBdXRK42MSyB2kCttI6G3swwJIryfh5wwsXMA0E(M47JWP6CRtfi0YcIN7h9akzcMppVx0xW9vUet)zXWHKP7MDXy(JZ3eTAvfz3JDmj3)FSD(DRH3GnYbcss7XiDn2IqDzWQu(b1S4n8p66Ghyhp4NNg2pNREJuv5jpWybtBipnnPNYgbntmSpscVZcjiRTnpkOqzRT8G8YOGvfl7TbnlCfoHvQIQYf(EbCMHnQZv0fHd95HbBWLh0GYqbtVSGK73nBcmHS5BdSslIJsM3dPnuk0LwH5clSY84hGLXphgTtH6GJGqDatOEPv9n(50sMh52GvG4nm4rXjqu6qyoilAnCOhORPtyY4WuW6x6NtQSlWmckg1PmZ1axQ(8ImGLHTM41OCK9)8KjP45PRWdvHG)NKkAY2XQ3BrGlmCCDCcW4zB3u4hVa0Balw5tNmu5ZxVoAEm6c7A4Ws4sG8X)cMEqw6u3KXrA7O)35rgUX(8Yy0e060hyBLOdSGDZwL(53Sjlof2AESswHJf9dYva(mywF3SK0cMAa6pbE0iqjppkmnb2ZBH(WiM(WaD)cUoLPRz3IZDUec)bm3GBTpGZ((jlqwi6lrHBly72d0DbyUMFGDsdw7c8WE7xl6ZQ4AQ7e44ZNU2mqkq33b1O3WuABK2(yqCY(rAeM5kGZxW84xfStovChPGRW8Ocz308rJ)1QTrmdrnguHRGs6YnurzJbioEiJSL1Nh0lmx5(GhAIqjAMyl17rRwaD4ppoIP4FjNgEUSsJ8rLzsCsMh9aellgaZMvb3TnQAAK51aW5Ne)QRd3m)kBEhdpZpcnvIeyT99RaVa3foV36GVSB2RbdnmkS0kU67O4zPEEXWM8dYdJsYXbvghA5eO9qr0HkoVzld41od)pQhJyw2K)y4sqEdX7DVYZvzUQzqH3oxkSwBrO5PhPH6om3HS9a5WLzm9JvC2(UkFKv7t9us8qYjklWuKNGKfwZIhvOuSb4zF4Z9dNNtftAZAf21H1dRjcuzFa0)QZbJL8somYvrVHlS4H8KVDZM0ScEIn3cXyfbJdKczpYn)hYceQ0FaMVtpzwsAj4gMcsJEU2LAyd9pd7Odr2DrW2vW8G)hcccom4de1HzKzrWQ8iPPgZHuEYJZH52FtAEEm(Ah0bB(CkCOtgNNuAtvMMEiY3COmBGCperjrRJJ4hjwGMS8fAWGDs3SX(Rj2XjvDkZY8RBJrv84v9PQYDpoxlFCtJKvv2)u6Cqr(VhHubxPErmysClOlNhNHk)3gTm4HygceFogdoyBceFr49SdgSKYSRuBKIwReoMS0BCkX6kNzePPkmZc2UR(tdt3wMQ5HSUY6I0w3KfnQpGi5XwjCAJMJBJThMwJSzIKTqExA706Pp2kM5F7M(FTDtZ8daYLOcs)z1QgWKTM5(m3NBU7UO1gqwTj9Zrz(Xjl2wVxIC1TGkkLL7Yu7knlrUceo6kd3g0mwNMMGGlCV)TPFbx2OSKuPuTSoecxB2M1SywaVwNs2Zj8XyB(MhKe6Cc5dGWWSMSwA7Tuk7AhaFgXjTYSlA6q(0ARZL6k9ehF3MfWJEcvJFx)6ZMnSPxja2Mh5d816CkZTQb99ysyLdUQLpVmYVFijmMHi5VemhHkD3m8t3IPOYb8OyzujLub7rec0nI6fFSbWdwSfFaZ1zE9oyeC0gyrGktEi9Eu7mmDE0xu2pCXQ12TlngfWjv)1Ckv1Qyh7ggP2mALrY9B)1PHBXmEstdvb0nRuO0bbBY5AabCzEkeZiL)F4JrXZRDrT3qf0eimPi2kn3bhvUdQKBokWgl5zWMfztm0LWkEkda4UTKlkZQYErdQPHYmZRiV9JL0kpcpLjkdCYJY)2vbi5QCE9)kgRGMaYhEPL(l4i1HJCBodNIFsGv(UzFIdwUg2Y1AYILThESf4VWLOiUe5xLWsGOUcHbw(iKZfqUR4SxAuNk9(DTatVNtu(LpkqSEtvwoJqiKRPaqzxq5rq4ezDsqPk0EL5fjQssJIUme6wPBqfSQsGCg5YXQbva(8wvqfDQI(fkiOWFKRt9bgKvyM9Fmlnen(NixjZkTSfbHm1SHCl(RtX6FuXAsCHRdSdySKOwNZlx6ECKWCwxe96fkB3qoQm(EJqSjvpUMc4Tfb0oIfMUMUTyJBJF42I0flKTmRci4nokms7lwkfINyqUdgwz3QH6)Gd2vvK4c4gYqhLPwJMMw7VPI2iHx(bW9xQ55CDCEu2JI6ursr28kkvMkclZFuZY8)bmWVhncxP3XHAaffSyS(Xx9PLBtql6SZy8Zukg1X2PGxnjiRtuJK35eGQiZCEglcT6bf8qq8kUeHnoze6edIzQ1i4x79zGnVGnwo2RyggkJvJOKSQNVAW9ZuxzftwcsPGjOpexfU(jnyfO7nuLYIsj1OQ3DQvmPl8Ddv9U7biRR5vDVJt4HKkI4CFD)YxPAt2U9UkYAHLOekyGxi4EUHD6tD7FKyNyXZHMOqnIAvarSfyoz8yUQUhoS7GalZ1rB83(WV99SweQOmbQYggaYycXLa2Bm6BG6KSy0ispXjOXJp(3ALB1RyWFiF2vR(sdSNkS1yVnu5RX0BG94xS3ijkjSZ6Oi2uPh0IRC0TzCAF99oqpidLWPkTh4Um7ucAIy1gn2iofnz8lPQdYQ2IZWzMsLDRglXXnGH5013guqL9OIAeVNRy6k1OMPQcHFCD2Jvpkilmijsi2ft)bv)e1Q9uDgPsV4GQLX76Ba)xWAeuD3GmrEwa7zPXe2tLpJvgNppq508C7NeTFqSg3GYeBi8sw1RFYr2vpkBqTUFmqP7wo8ownXA3gGmaihzg5koFyIVGkJm1jFOfTEvfopyGwuRokbolhX0eUSsc2uJpiB9sPKXAz(uxMfqM13WUNzfvAvgg0HoypYHdWDM9w)C)a(X7Rpww7PXhwZhs7i2ULK207m06hi)2q6J1r8UFIARyS5edekm2KabPmhmU70QeWqhS8etYlZYs3rRockAj9XWnN5AC3SFlz1JkGQxbOYO3Crnqkk9myBtxYbADEsPclh1Swp0AxXCsv2x2J(UX0dAeANJaJ(TjSKoLS28yQhvNqu2sScnWGX2Hco8F4PGrNwRIwEsikguUZyxGIDZwYAuASiqRIyNJqe3QOMZG0B3eYzYQlncxyFghkXHQpfNMrvfsQCiRz0Z86Zz44qDpK2gkOn4y2pTW8uz1OXobPeHLKWOvvtBo)(AqbssRv0f1O21qeoe1InTYsOeSLte4w2PY5ceQkSlMSnhmahLn89(mbRh9ZyI1UI4xQlIzg4AiloIFXpukkf9CuNz)Db4Eo6uJBshIxc3KygsgTtPFXjHM1w)E7DIPe3FDUpxlHDuaevRE0N1(377RARxYvoDXGiNcnqJOQFjBxIrTmqclD5ZBzVlN1T1anwEvElgnO3yj3Yg6JJ7lk8HTgDvgiiBkBoQaprv2BByrBwvNhjfgEhZIj4zcifjCQY(EvhGskkN0GYt3dTqdgOS9Tvkep)Yy4ScfpJCqmag8GfG2lwHwklIkJqHPh1GB)ngrTZ5NuHOOw8eQTnbo5(qOa6TIbnSw)4Yi0rX)dqFbz)JDZ(p57pSOK3aYlEjSlwIUQNZuJPlODpsmifz1CaLY1ZAtbkS2zKauJL51b4M0NgiSP8vcKB7XM3mOZn7kWHLTBiWt3fULAq0AjUxbURn5rwhqz6DYH2kzzTz9d4ES12cYz5USQyaCSsslwlpMLPQmeouYnSHEqHZ4k315Mk75pbKdeM(cTcGYKRhekzYWtJHu6aTTnPvEgn6h8sZr)(F9TF4hy3Obmnb8w7fJJcKR3gKxHaaQCySJDu6Fqps0pMiDoxBcLV(MdgVRXMfCs1nm0EWqhuNNoHDPbQKZlIZIUDvA6C3OZDOReEhoQwQBJYaNKS70ItW7o41skNzgl5VyB2JUrB7ySwy(O5fzbR8rLFkm5ek1YleztE(rCi4zs(yQ66ZFVuLLNr9ha1XDZ(Hk9rT4J33i0DG(MI7in6L)f1aytkYSbgQWJ52OfSwnAt6MnmNk8oI4VwoJLWrmFlE9oQbRlDHgWEvZcIodQ9OIASwD0fNnnHhsnEDbaKQr03asVETO278Q831iqyjmYQz3jSiMRamTgP069mE4lmVlOEyfd20Cs(UL(l6sHQNiomzDKJXMUM6kEjDwX6uzj8Nyuys8I4WamLwUegNJyw1tzaYMcg)xhK8ynKrYAchYUTNAtNiuGoIQbuO(1kNL13nbku)(AHYVn46T24vIMzEtwWJrKTU4hQgd2jw4G4rEGDEdhRV8LPBxn329)g1fs5ayc5meChQYXt6GPpDB0k8DUy8FswmP0wpm454HHuDLaRcfPoxSyyVfVUccEKWvCZLGwvbKPbz037oXzUryhDN1H15Ecd0ZUS9yrnYfytqeoqR4wknQ7tGJx2v4eF)9qHpwvnFvQLVX1vZE4enCo2uirCfMgbtdCEmSGLcEf7NTnXvbHPI8OnV6AoobfkOIPRFkkkGBnuzSnKIF5DQ(qSGQPAN8n0keue6kc7bAiBrApOCmG9a2Ge(q06GYqEZwUqoGiTgMuQLk1lJG5Oyr2Xw4Z52v4(LQRwI4JyVlDfeVM1H2we0NFic6kptKDsvhDVAegvCAr5CDxJM5vk7HSTf4BADHe8CuxmNhvpHcLuPqHmMn66a4SN5KeCmqlufCkml)5kPRxxp1nzrp4JBAdKKl2qPXEn6DH)QxtE2RLlsQiwaCHig)Jer0kCKStLYGhXS59aKLi(KYV07g((BU(ZbzjWubH79jSM8XR5FVgWWO4vCmfEfwwG)3T8lfEo7B0Naq7zDa70kONMaXf3B3p)3yFh2mab1mnbwk2JFv15aZV80Efp0ehJOs)bgzNbFPB9ACj9Ai)9cL2Kt9vgvlNvfGJ0MwsqLeZ7UFMqOQEVX2pH7iAsujvsnsKe1tDw3Y8QMUI2etF77A5mlFaIIG1QJylNvzan1MvkSoByJsPVZ2V9PlEH2NSmVhH9jxu8HVpzzwpU7tvjZTFBrVJM00UhTAuNLBzRoBBzUpcBtwM5NTI1x559zjjSAvD)uao3I5Eteh0n6BV9N0zFlUuEMNQgyXh7ZWtL7j(5sVhF3w2myVFQa284FmvbEPKPwM2d20k90MYatkMv6heSaxKONJ1XZzwAxnzKxNtO7hHNEISZC(tD4jBs0opNs(cDVAqVXD960PQsItNmU)tp5k(6NEISDD6w(5sXClps5sa0Tf7SFvfBV9BeXMqHCOLy9nQmSMO2EVfzOZBzjEUhLgBX3NEdIO7(ZwdKySaVurzoWIDXNRa59Vit7W(hDVHKExcNVNryAz7ra2pHgRAvu0zvB59EiZijpwIy)(XNUoHIWgrDWugwTgOjbqT7hzzjOJdGSCoFga8PnVwbauF(TyUOgehc6vbKnzX4pXKG40G32zoEq8Vikr5dd3(WB(1HJVeVkJPlIxv)DhvEV6724PtER4gkEw8IjNiv3Zkut)zQxt92lspMk3wNHaZprVamNLUzsEuXzSAFmzyBMcPRGO6B)U(0VUCDsq2ZS4itNmCSN9lc3vtU0J1idKtVaMsCYRmURFJ9ah4vkke3uptV4THOE6PtqYQRnPMSxF2(6XJ4UA44NEYoXnvI2QPoCRGxrq5psDZTgXA1T2t0p8(0tDSGp)vtSwTpGnjHaxNtQFVjd621oTQehMg9ATcEp9KRQ3rlQ7ltdAv9ItkqgrNXlU2Kb4oTf(z6qDwvvjz6OgxjmGuP90EWkddvVi81uLayn9xrt9uPXd5mHulM6z2NUtNm4sVo2HDhuaPkzFxp9(TEAFVtEW(f10JCVuuFFn2s3yJLW2BNaecfbNdLEN6Qrqy5YYHbJDKCGvfHU6uq9fI0IjYb91Fdruh4R0Xvjo8O2kOpkulzHKrAIXbM47(Uk)EvKLTdiq2l(qifsgPvI6e72KjdRssdBLM5XPBZXxP8zWITB2)eELjP2xeoKAxPhVAszXtpT(675jBZv5ItcIjB6vqMQ02yT9gxn5c30FNdMbE6jJlO4vtQF6PLJVRNExpj0bma)XZygNkKx25qlYedtIysBy)iG8Dv2SGF(X6AE))P7LiP2b(euiTxQAthy3EOJygeaICbeZtNoNqDje9m)uq61fJcYcgjeZd8gLiLy5Igozu3UsoRKVOwNfPCbbN067h4zeTOp6)vQH(B)K1o3AIm9Kmgld8ffuzhDiY(gbzrd)0AlfZgPCOs06hp9unvFXyLaH1V2fk29vEiOntSX0vkKkrdN8pXr71X5DQB6e73NUNEIwdR7HfKyDysTK)fzbjFr5yoho23Ymxumd4sQTqtY(QjJ9KCK1Vs3Ya7tZOrltrLADCFH2eB5QxMn(jvJiuLVkCodeHs)YEgLwVPAEY27Q(CJt54eYq9Xr2Cxn2ZTThIdRKHCuzmMqul28gn2J60V0z)YViWq1XxUlof5EeALsnCadJACiTSDpYal5EuqgB71yEJVAYqA3K0UuBNVrERyPLHTilAta14M1QGFOey3jdgwIeHZ09)Zdg221r9SKkAhSFzyQxA2VTOhHzfNNZQVsAnCONNljPZ8Ru(jGXtjNYPxAKb5bsTdoJlJr9aypPJPTWx7Md6sBbfn8ZTWFe(DCPTBlsw4u5shHmD5RD6cS70j6UIL9zRDVJBjD6abUo6R2BSs6DV6CsC3g03JmoWP7ZCR45WoeqopHRdj1ESNyjK4xKDdL0rujr3)ccuN7(Rhr6DuYBQr8X1ruO8GU1o)EUPvCo4IN(hUfpNMwhqQsnzS5hx7c6DE22TkZ7skDb0brTrH99Y8k2qHDkyBKFpHRDGAMvIXL70w2k6q2nPHlY7PdgJ5cbkAEAV4O(6uz9TSTMqPilIP6s9zsCjA33Ps2Fz5CvFjz375AS(CPEjypK5dujo8RaRPAH86YYZCpYA97Q(ziFpVOJhJB3QoNOynHHkVX9v0RJomGISDfaD7aqDhOgYan9QHD9iXYSKRMuIU90bJlLQ5gxAvpxVp57Wca4zSB8IDTt13IuvHW9O2SF4zUr(S2I0Pk6y0RAez9rlORxMcIiGb(R1T)0yxs7MPI8P4wHE1KlglN5cpxM9ijn74745uywMfo1p591bcqCTt6sqQ7hqvSLL83SFBsb2po41IbkkM4n1(PXNzbJoOeYgj4cJA1RnHthWDDSF)g6tqO4pm)mzKjrivfBX43hyLK0Zg23ZA5)pVEh32X8jdnk5txc(VXFU7j4hPFEUTiggqjgu1mQBgd5lZeh9kAyjNoXnKMNszwr6x6ESOcuOF48KmRsdQfkOPYhiSF916xGE7QCU6gim2tDk9q)5tFN8pt8hZtasodoWFv5DR)EefbTGRTUA77Vj8nSym021KWYUSWZlw97REJ(A5l91Phokjb1iq0HMTDnuHj6Th2p9AKe3)AvxFdw8zu2I9P8eLRMs)cySzh7Obcoc)KNrV9wvyERLG3RHoHOsqEeQYjngqnvg5xd6pUROzL0FVIuKez3HpJAr2qjhTwQsd(OjZJTItCwCYV5(bdJw3UfjWyAXTXuoH0AnIgLmpFtBJtrBJcmtvRCvNtO10XuIoH4GHBfdRHM0Hm6CRbN3TvseTK6RpnmOp24m7HDD2mcgDSBcVQvm0(r7QbNxM7ZhT6alkM)r6xcjswPf1wUMhL)vEYIos7B31AhLU72u5SfD4sqhpsZdGugYF5fXnvwDkzRNAT2BPGSTvrwn21tn67EonOv2gNGUyhSMUnaKvRPkjPJwTHn8bD1LGLHdKEBc3nNTzrRzM)D5X(AwEmeoNi4STY3wFS4kWmwwf9goHXJ6iF7g(nrtoMaGcYEKN(o7lc)QeFWtz9A9UU1Y2AxDu(yROvjLJ332ZnUXp17tVRHnsmqIHY4l)n)3MywKruErK0MBHuYuBtC9PQ9FAnRDyreXFza)BRd8Bu3g7PCf2wj5StmDkwgf0(mB1bdjZ8S4kKmiv)zIZXJ8oH8l(lxk9sTl8bwJaZoU1bVvhD0bUyn0xEufZVIwQQTeqjqyj(XfrRlnKaJFnZ0uEztHFx066yGAxnILJQY6cH6IRHWDqCNVhm38fCAJYsspO3nd)ET7qEX5bYxuqQ3mNkcW9TJfGOgC79D6G(ELlEpHF2T8VTmadR9PBGHsaA5vJNx89Q3UQHC)b(xYqyLz59alZ4M0T9HDvGwW)wKLd1De7ArWIffhlEJmqRdvxkJ2iORRGxCYdP3JAtHPZJ(ctwsXgcRvAFPijl50eRYIolXF0gPovcs4fNG6bENqVsSVq8U5)l]] )