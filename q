[1mdiff --git a/app/sensors/system/routes.py b/app/sensors/system/routes.py[m
[1mindex 380fd31..76bb5ec 100644[m
[1m--- a/app/sensors/system/routes.py[m
[1m+++ b/app/sensors/system/routes.py[m
[36m@@ -1,5 +1,9 @@[m
[31m-from flask import Blueprint, jsonify[m
[32m+[m[32mfrom venv import logger[m
[32m+[m
[32m+[m[32mfrom app.sensors import light[m
 [m
[32m+[m[32mfrom flask import Blueprint, jsonify[m
[32m+[m[32mfrom app.lib import state as state_lib[m
 import config[m
 from app.lib.hardware import detect_model[m
 [m
[36m@@ -17,9 +21,28 @@[m [mdef _profile_for(model):[m
             return profile[m
     return {}[m
 [m
[32m+[m[32mdef restore_actuator_state():[m
[32m+[m[32m    """Restore light/pump to their last persisted state after a restart (#3)."""[m
[32m+[m[32m    global light_state, pump_state, brightness, speed[m
[32m+[m[32m    saved = state_lib.load_state()[m
[32m+[m[32m    brightness = saved.get("brightness", brightness)[m
[32m+[m[32m    speed = saved.get("speed", speed)[m
[32m+[m[32m    try:[m
[32m+[m[32m        if saved.get("light_on"):[m
[32m+[m[32m            light_state = True[m
[32m+[m[32m            light.set_duty_cycle(brightness)[m
[32m+[m[32m        if saved.get("pump_on"):[m
[32m+[m[32m            pump_state = True[m
[32m+[m[32m        logger.info("Restored actuator state: %s", saved)[m
[32m+[m[32m    except Exception as exc:[m
[32m+[m[32m        logger.error("Failed to restore actuator state: %s", exc)[m
[32m+[m[32m    return {}[m
[32m+[m
 [m
 @system_blueprint.route("", methods=["GET"])[m
 def get_system():[m
[32m+[m[32m    """Restore Actuator State after waitress restart and return system info. """[m
[32m+[m[32m    restore_actuator_state()[m[41m [m
     """Report identity, version, and the detected hardware model/profile."""[m
     model = detect_model()[m
     return jsonify([m
[1mdiff --git a/app/web/index.html b/app/web/index.html[m
[1mindex 4a40e7d..c86c6c7 100644[m
[1m--- a/app/web/index.html[m
[1m+++ b/app/web/index.html[m
[36m@@ -465,21 +465,21 @@[m
       for (const [path, [id, key]] of Object.entries(sensors)) {[m
         try { $(id).textContent = (await get(path))[key]; } catch { $(id).textContent = "n/a"; }[m
       }[m
[31m-      try {[m
[31m-        const w = await get("/distance"); const cm = w.distance;[m
[31m-        $("s-water").textContent = cm;[m
[31m-        $("s-water-gal").textContent = (w.gallons != null) ? w.gallons : "—";[m
[31m-        // Map ~5cm (full) .. ~20cm (empty) to a 0..100% bar.[m
[31m-        const pct = Math.max(0, Math.min(100, (1 - (cm - 5) / 15) * 100));[m
[31m-        $("s-water-bar").style.width = pct + "%";[m
[31m-        // Tank-low warning: larger distance = lower water (threshold from /system).[m
[31m-        const badge = $("s-water-status");[m
[31m-        if (waterLowCm != null && cm > waterLowCm) {[m
[31m-          badge.textContent = "LOW"; badge.style.cssText = "background:#c0392b;color:#fff;border-color:#c0392b";[m
[31m-        } else if (waterLowCm != null) {[m
[31m-          badge.textContent = "OK"; badge.style.cssText = "";[m
[31m-        } else { badge.textContent = ""; }[m
[31m-      } catch { $("s-water").textContent = "n/a"; $("s-water-gal").textContent = "n/a"; $("s-water-status").textContent = ""; }[m
[32m+[m[32m     // try {[m
[32m+[m[32m     //   const w = await get("/distance"); const cm = w.distance;[m
[32m+[m[32m     //   $("s-water").textContent = cm;[m
[32m+[m[32m     //   $("s-water-gal").textContent = (w.gallons != null) ? w.gallons : "—";[m
[32m+[m[32m     //   // Map ~5cm (full) .. ~20cm (empty) to a 0..100% bar.[m
[32m+[m[32m     //   const pct = Math.max(0, Math.min(100, (1 - (cm - 5) / 15) * 100));[m
[32m+[m[32m     //   $("s-water-bar").style.width = pct + "%";[m
[32m+[m[32m     //  // Tank-low warning: larger distance = lower water (threshold from /system).[m
[32m+[m[32m     //   const badge = $("s-water-status");[m
[32m+[m[32m     //   if (waterLowCm != null && cm > waterLowCm) {[m
[32m+[m[32m     //     badge.textContent = "LOW"; badge.style.cssText = "background:#c0392b;color:#fff;border-color:#c0392b";[m
[32m+[m[32m     //   } else if (waterLowCm != null) {[m
[32m+[m[32m     //     badge.textContent = "OK"; badge.style.cssText = "";[m
[32m+[m[32m     //   } else { badge.textContent = ""; }[m
[32m+[m[32m     // } catch { $("s-water").textContent = "n/a"; $("s-water-gal").textContent = "n/a"; $("s-water-status").textContent = ""; }[m
       try {[m
         const p = await get("/pump/stats");[m
         if (p.BusVoltage != null) { $("p-volt").textContent = p.BusVoltage; $("p-curr").textContent = p.BusCurrent; $("p-pow").textContent = p.Power; $("p-shunt").textContent = p.ShuntVoltage ?? "—"; }[m
