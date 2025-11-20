// MyWatchFaceView.mc
// Implémentation du design de watchface pour Garmin Connect IQ

using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Activity;
using Toybox.ActivityMonitor;
using Toybox.Time;
using Toybox.Time.Gregorian;

class CyberpunkView extends WatchUi.WatchFace {

    // Variables de cache
    private var screenWidth;
    private var screenHeight;
    private var centerX;
    private var centerY;
    private var scale;
    
    // Palette cyberpunk sobre
    private var bgColor = 0x000000;           // Noir pur

    // Dégradé cyan/bleu pour l'heure (clair -> foncé)
    private var timeColorLight = 0x00FFFF;    // Cyan vif
    private var timeColorMid = 0x00B8D4;      // Cyan moyen
    private var timeColorDark = 0x006B7D;     // Cyan foncé

    // Couleurs secondaires sobres
    private var secondaryColor = 0x5A6B7C;    // Gris-bleu sobre
    private var accentColor = 0x8B4FFF;       // Violet néon (accents)

    // Stats avec dégradés subtils
    private var heartColorLight = 0xFF2D6F;   // Rose vif
    private var heartColorDark = 0x8B1A3F;    // Rose foncé

    private var stepsColorLight = 0x00FFB3;   // Vert cyan vif
    private var stepsColorDark = 0x00805A;    // Vert cyan foncé

    private var batteryColorLight = 0xFFAA00; // Orange vif
    private var batteryColorDark = 0x996600;  // Orange foncé

    // Effets glow (très sombres)
    private var glowColor = 0x1A1A2E;         // Glow subtil

    // Polices personnalisées
    private var orbitronTimeFont;
    private var orbitronSmallFont;

    function initialize() {
        WatchFace.initialize();

        // Charger les polices personnalisées
        orbitronTimeFont = WatchUi.loadResource(Rez.Fonts.OrbitronTime);
        orbitronSmallFont = WatchUi.loadResource(Rez.Fonts.OrbitronSmall);

        // Charger le thème de couleurs
        loadColorTheme();
    }

    // Charger le thème de couleurs depuis les paramètres
    function loadColorTheme() {
        var theme = Application.Properties.getValue("ColorTheme");
        if (theme == null) {
            theme = 0; // Cyan Neon par défaut
        }

        if (theme == 0) {
            // Cyan Neon (actuel)
            timeColorLight = 0x00FFFF;
            timeColorMid = 0x00B8D4;
            timeColorDark = 0x006B7D;
            secondaryColor = 0x5A6B7C;
            accentColor = 0x8B4FFF;
            heartColorLight = 0xFF2D6F;
            heartColorDark = 0x8B1A3F;
            stepsColorLight = 0x00FFB3;
            stepsColorDark = 0x00805A;
            batteryColorLight = 0xFFAA00;
            batteryColorDark = 0x996600;

        } else if (theme == 1) {
            // Purple Dreams
            timeColorLight = 0xFF00FF;
            timeColorMid = 0xCC00CC;
            timeColorDark = 0x7B2FF7;
            secondaryColor = 0x8B6B9C;
            accentColor = 0xFF6FFF;
            heartColorLight = 0xFF2D9F;
            heartColorDark = 0x8B1A5F;
            stepsColorLight = 0xBB00FF;
            stepsColorDark = 0x6600AA;
            batteryColorLight = 0xFF88FF;
            batteryColorDark = 0xAA55AA;

        } else if (theme == 2) {
            // Green Matrix
            timeColorLight = 0x00FF00;
            timeColorMid = 0x00CC00;
            timeColorDark = 0x008800;
            secondaryColor = 0x4A7C5A;
            accentColor = 0x66FF66;
            heartColorLight = 0x88FF66;
            heartColorDark = 0x448833;
            stepsColorLight = 0x00FF88;
            stepsColorDark = 0x008844;
            batteryColorLight = 0xAAFF00;
            batteryColorDark = 0x668800;

        } else if (theme == 3) {
            // Red Alert
            timeColorLight = 0xFF0000;
            timeColorMid = 0xCC0000;
            timeColorDark = 0x880000;
            secondaryColor = 0x7C5A5A;
            accentColor = 0xFF6666;
            heartColorLight = 0xFF4444;
            heartColorDark = 0xAA2222;
            stepsColorLight = 0xFF8844;
            stepsColorDark = 0xBB4422;
            batteryColorLight = 0xFFAA00;
            batteryColorDark = 0xBB6600;

        } else if (theme == 4) {
            // Blue Ice
            timeColorLight = 0x00DDFF;
            timeColorMid = 0x0088CC;
            timeColorDark = 0x004488;
            secondaryColor = 0x5A7C8B;
            accentColor = 0x66CCFF;
            heartColorLight = 0x4488FF;
            heartColorDark = 0x2244AA;
            stepsColorLight = 0x00BBFF;
            stepsColorDark = 0x006688;
            batteryColorLight = 0x88DDFF;
            batteryColorDark = 0x4488AA;

        } else if (theme == 5) {
            // Orange Sunset
            timeColorLight = 0xFFAA00;
            timeColorMid = 0xDD8800;
            timeColorDark = 0x996600;
            secondaryColor = 0x8B7C5A;
            accentColor = 0xFFCC44;
            heartColorLight = 0xFF6644;
            heartColorDark = 0xBB3322;
            stepsColorLight = 0xFFDD66;
            stepsColorDark = 0xBB8833;
            batteryColorLight = 0xFFCC00;
            batteryColorDark = 0xAA7700;
        }

        glowColor = 0x1A1A2E;
    }

    // Chargement des ressources
    function onLayout(dc) {
        screenWidth = dc.getWidth();
        screenHeight = dc.getHeight();
        centerX = screenWidth / 2;
        centerY = screenHeight / 2;
        scale = screenWidth / 240.0;
    }

    // Appelé quand l'affichage est visible
    function onShow() {
    }

    // Appelé quand les paramètres changent
    function onSettingsChanged() {
        loadColorTheme();
        WatchUi.requestUpdate(); // Forcer le rafraîchissement de l'affichage
    }

    // Mise à jour principale (appelée chaque seconde en mode 1Hz)
    function onUpdate(dc) {
        // Toujours redessiner le fond pour éviter la superposition des arcs
        drawBackground(dc);

        // Dessiner les éléments dynamiques
        drawTime(dc);
        drawDate(dc);
        drawStats(dc);
    }

    // Dessiner le fond et les éléments statiques
    function drawBackground(dc) {
        // Fond noir pur
        dc.setColor(bgColor, bgColor);
        dc.clear();

        // Arc de progression EN ARRIÈRE-PLAN (dessiné en premier)
        drawProgressArc(dc);

        // Cercle extérieur décoratif - effet dégradé avec plusieurs cercles
        var radius = (screenWidth / 2) - (5 * scale);

        // Cercle externe (couleur foncée)
        dc.setColor(timeColorDark, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3 * scale);
        dc.drawCircle(centerX, centerY, radius);

        // Cercle médian (couleur moyenne) - légèrement plus petit
        dc.setColor(timeColorMid, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2 * scale);
        dc.drawCircle(centerX, centerY, radius - (1 * scale));

        // Cercle intérieur subtil
        radius = radius - (8 * scale);
        dc.setColor(glowColor, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1 * scale);
        dc.drawCircle(centerX, centerY, radius);

        // Marqueurs d'heures (12, 3, 6, 9) - cyan vif
        dc.setColor(timeColorLight, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2 * scale);

        var markerLength = 10 * scale;
        var markerRadius = radius + (5 * scale);

        // 12h (top)
        dc.drawLine(centerX, centerY - markerRadius,
                   centerX, centerY - markerRadius + markerLength);
        // 3h (right)
        dc.drawLine(centerX + markerRadius, centerY,
                   centerX + markerRadius - markerLength, centerY);
        // 6h (bottom)
        dc.drawLine(centerX, centerY + markerRadius,
                   centerX, centerY + markerRadius - markerLength);
        // 9h (left)
        dc.drawLine(centerX - markerRadius, centerY,
                   centerX - markerRadius + markerLength, centerY);

        // Points décoratifs aux coins (ne pas afficher si mode "All Three")
        var arcDataType = Application.Properties.getValue("ArcDataType");
        if (arcDataType == null) {
            arcDataType = 0; // Par défaut
        }

        // Afficher les points décoratifs uniquement si ce n'est pas le mode "All Three" (arcDataType == 3)
        if (arcDataType.toNumber() != 3) {
            drawDecorativePoints(dc);
        }
    }

    // Arc de progression circulaire
    function drawProgressArc(dc) {
        var stats = System.getSystemStats();
        var activityInfo = ActivityMonitor.getInfo();

        // Récupérer le type de données à afficher depuis les paramètres
        var arcDataType = Application.Properties.getValue("ArcDataType");
        if (arcDataType == null) {
            arcDataType = 0; // Batterie par défaut
        }

        // Option 3: Afficher les trois arcs simultanément
        if (arcDataType == 3) {
            drawThreeArcs(dc, stats, activityInfo);
            return;
        }

        var percent = 0;
        var arcColorLight = timeColorLight;
        var arcColorDark = timeColorDark;

        // Calculer le pourcentage selon le type de données
        if (arcDataType == 0) {
            // Batterie
            percent = stats.battery;
            arcColorLight = batteryColorLight;
            arcColorDark = batteryColorDark;
        } else if (arcDataType == 1) {
            // Steps
            var stepGoal = Application.Properties.getValue("StepGoal");
            if (stepGoal == null || stepGoal <= 0) {
                stepGoal = activityInfo.stepGoal;
            }
            percent = (activityInfo.steps * 100.0) / stepGoal;
            if (percent > 100) { percent = 100; }
            arcColorLight = stepsColorLight;
            arcColorDark = stepsColorDark;
        } else if (arcDataType == 2) {
            // Calories
            var calorieGoal = Application.Properties.getValue("CalorieGoal");
            if (calorieGoal == null || calorieGoal <= 0) {
                calorieGoal = 2000; // Objectif par défaut
            }
            var calories = activityInfo.calories;
            if (calories != null) {
                percent = (calories * 100.0) / calorieGoal;
                if (percent > 100) { percent = 100; }
            }
            arcColorLight = heartColorLight;
            arcColorDark = heartColorDark;
        }

        var radius = (screenWidth / 2) - (10 * scale);
        var startAngle = 90; // Commencer en haut (90° = position 12h)
        var sweepAngle = -((percent * 360) / 100); // 270° max (3/4 de cercle)

        // Effet dégradé sur l'arc - dessiner 2 arcs superposés
        // Arc externe (couleur foncée)
        dc.setColor(arcColorDark, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(5 * scale);
        dc.drawArc(centerX, centerY, radius, Graphics.ARC_CLOCKWISE,
                   startAngle, startAngle + sweepAngle);

        // Arc interne (couleur vive)
        dc.setColor(arcColorLight, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3 * scale);
        dc.drawArc(centerX, centerY, radius, Graphics.ARC_CLOCKWISE,
                   startAngle, startAngle + sweepAngle);
    }

    // Dessiner les trois arcs de progression simultanément
    function drawThreeArcs(dc, stats, activityInfo) {
        var startAngle = 90; // Commencer en haut (90° = position 12h)
        var arcThickness = 3 * scale; // Épaisseur des arcs
        var arcSpacing = 6 * scale; // Espacement entre les arcs

        // Arc 1 (extérieur): Batterie - orange
        var batteryPercent = stats.battery;
        var batterySweep = -((batteryPercent * 360) / 100);
        var radius1 = (screenWidth / 2) - (10 * scale);

        dc.setColor(batteryColorLight, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(arcThickness);
        dc.drawArc(centerX, centerY, radius1, Graphics.ARC_CLOCKWISE,
                   startAngle, startAngle + batterySweep);

        // Arc 2 (milieu): Steps - vert
        var stepGoal = Application.Properties.getValue("StepGoal");
        if (stepGoal == null || stepGoal <= 0) {
            stepGoal = activityInfo.stepGoal;
        }
        var stepsPercent = (activityInfo.steps * 100.0) / stepGoal;
        if (stepsPercent > 100) { stepsPercent = 100; }
        var stepsSweep = -((stepsPercent * 360) / 100);
        var radius2 = radius1 - arcThickness - arcSpacing;

        dc.setColor(stepsColorLight, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(arcThickness);
        dc.drawArc(centerX, centerY, radius2, Graphics.ARC_CLOCKWISE,
                   startAngle, startAngle + stepsSweep);

        // Arc 3 (intérieur): Calories - rose
        var calorieGoal = Application.Properties.getValue("CalorieGoal");
        if (calorieGoal == null || calorieGoal <= 0) {
            calorieGoal = 2000;
        }
        var caloriesPercent = 0;
        var calories = activityInfo.calories;
        if (calories != null) {
            caloriesPercent = (calories * 100.0) / calorieGoal;
            if (caloriesPercent > 100) { caloriesPercent = 100; }
        }
        var caloriesSweep = -((caloriesPercent * 360) / 100);
        var radius3 = radius2 - arcThickness - arcSpacing;

        dc.setColor(heartColorLight, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(arcThickness);
        dc.drawArc(centerX, centerY, radius3, Graphics.ARC_CLOCKWISE,
                   startAngle, startAngle + caloriesSweep);
    }

    // Points décoratifs
    function drawDecorativePoints(dc) {
        var margin = 50 * scale;
        var pointSize = 3 * scale;

        // Points cyan (haut)
        dc.setColor(timeColorLight, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(margin, margin, pointSize);
        dc.fillCircle(screenWidth - margin, margin, pointSize);

        // Points violet (bas)
        dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(margin, screenHeight - margin, pointSize);
        dc.fillCircle(screenWidth - margin, screenHeight - margin, pointSize);
    }


    // Dessiner l'heure avec effet glow cyberpunk
    function drawTime(dc) {
        var clockTime = System.getClockTime();
        var hour = clockTime.hour;
        var minute = clockTime.min;
        var second = clockTime.sec;

        // Récupérer le format d'heure (0 = 12h, 1 = 24h)
        var timeFormat = Application.Properties.getValue("TimeFormat");
        if (timeFormat == null) {
            timeFormat = 1; // 24h par défaut
        }

        // Convertir en format 12h si nécessaire
        var displayHour = hour;
        if (timeFormat == 0) {
            // Format 12h
            if (hour == 0) {
                displayHour = 12;
            } else if (hour > 12) {
                displayHour = hour - 12;
            }
        }

        // Formater les heures et minutes
        var hourString = displayHour.format("%02d");
        var minuteString = minute.format("%02d");

        var yPos = centerY - (45 * scale);

        // Espacement entre heures et minutes (pour les deux points)
        var spacing = 10 * scale;

        // Position des heures (à gauche du centre)
        var hourX = centerX - spacing;

        // Effet dégradé heures - 3 couches
        // Couche glow (très sombre)
        dc.setColor(glowColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(hourX + (3 * scale), yPos + (3 * scale),
                   orbitronTimeFont, hourString,
                   Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Couche ombre (cyan foncé)
        dc.setColor(timeColorDark, Graphics.COLOR_TRANSPARENT);
        dc.drawText(hourX + (2 * scale), yPos + (2 * scale),
                   orbitronTimeFont, hourString,
                   Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Heures principales (cyan vif)
        dc.setColor(timeColorLight, Graphics.COLOR_TRANSPARENT);
        dc.drawText(hourX, yPos,
                   orbitronTimeFont, hourString,
                   Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Position des minutes (à droite du centre)
        var minuteX = centerX + spacing;

        // Effet dégradé minutes - 3 couches
        // Couche glow (très sombre)
        dc.setColor(glowColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(minuteX + (3 * scale), yPos + (3 * scale),
                   orbitronTimeFont, minuteString,
                   Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Couche ombre (cyan foncé)
        dc.setColor(timeColorDark, Graphics.COLOR_TRANSPARENT);
        dc.drawText(minuteX + (2 * scale), yPos + (2 * scale),
                   orbitronTimeFont, minuteString,
                   Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Minutes principales (cyan vif)
        dc.setColor(timeColorLight, Graphics.COLOR_TRANSPARENT);
        dc.drawText(minuteX, yPos,
                   orbitronTimeFont, minuteString,
                   Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Séparateur clignotant (deux points) - centré entre heures et minutes
        if (second % 2 == 0) {
            // Glow autour des points
            dc.setColor(timeColorDark, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(centerX, yPos - (5 * scale), 3 * scale);
            dc.fillCircle(centerX, yPos + (5 * scale), 3 * scale);

            // Points principaux
            dc.setColor(timeColorLight, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(centerX, yPos - (5 * scale), 2 * scale);
            dc.fillCircle(centerX, yPos + (5 * scale), 2 * scale);
        }

        // Indicateur AM/PM pour format 12h
        if (timeFormat == 0) {
            var ampm = (hour < 12) ? "AM" : "PM";
            var ampmY = yPos + (20 * scale);

            // Glow AM/PM
            dc.setColor(glowColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX + scale, ampmY + scale,
                       orbitronSmallFont, ampm,
                       Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

            // AM/PM principal
            dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, ampmY,
                       orbitronSmallFont, ampm,
                       Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // Secondes avec effet numérique sobre
        var secondString = second.format("%02d");
        var secondY = centerY - (5 * scale);

        // Glow secondes
        dc.setColor(glowColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX + scale, secondY + scale,
                   orbitronSmallFont, secondString,
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Secondes principales (gris-bleu sobre)
        dc.setColor(secondaryColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, secondY,
                   orbitronSmallFont, secondString,
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Dessiner la date avec style cyberpunk
    function drawDate(dc) {
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

        // Format: "MER 19 NOV"
        var dateString = Lang.format("$1$ $2$ $3$", [
            today.day_of_week.toUpper().substring(0, 3),
            today.day,
            today.month.toUpper().substring(0, 3)
        ]);

        var dateY = centerY + (10 * scale);

        // Ligne décorative au-dessus de la date (violet accent)
        dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        var lineWidth = 60 * scale;
        dc.drawLine(centerX - lineWidth, dateY - (8 * scale),
                   centerX + lineWidth, dateY - (8 * scale));

        // Date avec léger effet glow
        dc.setColor(glowColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX + scale, dateY + scale,
                   orbitronSmallFont, dateString,
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Date principale (accent violet)
        dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, dateY,
                   orbitronSmallFont, dateString,
                   Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Dessiner les statistiques avec style cyberpunk
    function drawStats(dc) {
        var activityInfo = ActivityMonitor.getInfo();
        var stats = System.getSystemStats();

        var yPosition = centerY + (30 * scale);
        var iconSize = 12 * scale;

        // Calculer les objectifs atteints
        var stepGoal = Application.Properties.getValue("StepGoal");
        if (stepGoal == null || stepGoal <= 0) {
            stepGoal = activityInfo.stepGoal;
        }
        var stepsGoalAchieved = activityInfo.steps >= stepGoal;

        var calorieGoal = Application.Properties.getValue("CalorieGoal");
        if (calorieGoal == null || calorieGoal <= 0) {
            calorieGoal = 2000;
        }
        var calories = activityInfo.calories;
        var caloriesGoalAchieved = (calories != null && calories >= calorieGoal);

        // Fréquence cardiaque avec dégradé rose
        var heartRate = getHeartRate();
        if (heartRate != null) {
            var xPos = centerX - (85 * scale);
            drawHeartIcon(dc, xPos, yPosition, iconSize);

            // Effet glow
            dc.setColor(glowColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(xPos + (17 * scale), yPosition + scale,
                       orbitronSmallFont, heartRate.toString(),
                       Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

            // Ombre foncée
            dc.setColor(heartColorDark, Graphics.COLOR_TRANSPARENT);
            dc.drawText(xPos + (16.5 * scale), yPosition + (0.5 * scale),
                       orbitronSmallFont, heartRate.toString(),
                       Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

            // Valeur principale (rose vif)
            dc.setColor(heartColorLight, Graphics.COLOR_TRANSPARENT);
            dc.drawText(xPos + (16 * scale), yPosition,
                       orbitronSmallFont, heartRate.toString(),
                       Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // Pas avec dégradé vert
        var steps = activityInfo.steps;
        var stepsK = steps / 1000.0;
        var stepsString = stepsK.format("%.1f") + "K";

        var xPos = centerX - (20 * scale);
        drawStepsIcon(dc, xPos, yPosition, iconSize);

        // Effet glow
        dc.setColor(glowColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xPos + (17 * scale), yPosition + scale,
                   orbitronSmallFont, stepsString,
                   Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Ombre foncée
        dc.setColor(stepsColorDark, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xPos + (16.5 * scale), yPosition + (0.5 * scale),
                   orbitronSmallFont, stepsString,
                   Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Valeur principale (vert vif)
        dc.setColor(stepsColorLight, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xPos + (16 * scale), yPosition,
                   orbitronSmallFont, stepsString,
                   Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Icône d'accomplissement pour les steps
        if (stepsGoalAchieved) {
            drawAchievementIcon(dc, xPos + (30 * scale), yPosition + (15 * scale), 4 * scale, stepsColorLight);
        }

        // Batterie avec dégradé orange
        var battery = stats.battery.toNumber();
        var batteryString = battery.toString() + "%";

        xPos = centerX + (45 * scale);
        drawBatteryIcon(dc, xPos, yPosition, iconSize, battery);

        // Effet glow
        dc.setColor(glowColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xPos + (21 * scale), yPosition + scale,
                   orbitronSmallFont, batteryString,
                   Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Ombre foncée
        dc.setColor(batteryColorDark, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xPos + (20.5 * scale), yPosition + (0.5 * scale),
                   orbitronSmallFont, batteryString,
                   Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Valeur principale (orange vif)
        dc.setColor(batteryColorLight, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xPos + (20 * scale), yPosition,
                   orbitronSmallFont, batteryString,
                   Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        // Icône d'accomplissement pour les calories (affichée sous le coeur - première stat)
        if (caloriesGoalAchieved) {
            var heartXPos = centerX - (85 * scale);
            drawAchievementIcon(dc, heartXPos + (30 * scale), yPosition + (15 * scale), 4 * scale, heartColorLight);
        }
    }

    // Obtenir la fréquence cardiaque
    function getHeartRate() {
        var activityInfo = Activity.getActivityInfo();
        if (activityInfo != null && activityInfo.currentHeartRate != null) {
            return activityInfo.currentHeartRate;
        }
        
        // Sinon, essayer le dernier échantillon
        var sample = ActivityMonitor.getHeartRateHistory(1, true)
                                    .next();
        if (sample != null && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
            return sample.heartRate;
        }
        
        return null;
    }

    // Icône cœur simplifié avec dégradé
    function drawHeartIcon(dc, x, y, size) {
        // Ligne ECG stylisée
        var points = [
            [x, y],
            [x + 2, y - 2],
            [x + 4, y + 2],
            [x + 6, y - 4],
            [x + 8, y],
            [x + 10, y - 2],
            [x + 12, y]
        ];

        // Ombre
        dc.setColor(heartColorDark, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        for (var i = 0; i < points.size() - 1; i++) {
            dc.drawLine(points[i][0] + 0.5, points[i][1] + 0.5,
                       points[i+1][0] + 0.5, points[i+1][1] + 0.5);
        }

        // Ligne principale
        dc.setColor(heartColorLight, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1.5);
        for (var i = 0; i < points.size() - 1; i++) {
            dc.drawLine(points[i][0], points[i][1],
                       points[i+1][0], points[i+1][1]);
        }
    }

    // Icône pas avec dégradé
    function drawStepsIcon(dc, x, y, size) {
        // Ombre
        dc.setColor(stepsColorDark, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x + 3.5, y - 2.5, 2);
        dc.fillRoundedRectangle(x + 1.5, y + 0.5, 4, 6, 1);

        // Principale
        dc.setColor(stepsColorLight, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x + 3, y - 3, 2);
        dc.fillRoundedRectangle(x + 1, y, 4, 6, 1);
    }

    // Icône batterie avec dégradé
    function drawBatteryIcon(dc, x, y, size, level) {
        // Ombre du contour
        dc.setColor(batteryColorDark, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawRoundedRectangle(x + 0.5, y - 4.5, 14, 8, 1);

        // Contour principal
        dc.setColor(batteryColorLight, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1.5);
        dc.drawRoundedRectangle(x, y - 5, 14, 8, 1);

        // Borne +
        dc.fillRectangle(x + 14, y - 2, 2, 2);

        // Niveau (proportionnel) avec dégradé
        var fillWidth = (level * 10) / 100;
        if (fillWidth > 0) {
            // Ombre
            dc.setColor(batteryColorDark, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(x + 2.5, y - 2.5, fillWidth, 4);
            // Principal
            dc.setColor(batteryColorLight, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(x + 2, y - 3, fillWidth, 4);
        }
    }

    // Icône d'accomplissement - étoile cyberpunk
    function drawAchievementIcon(dc, x, y, size, color) {
        // Dessiner une étoile à 5 branches
        var outerRadius = size;
        var innerRadius = size * 0.4;

        // Points de l'étoile
        var points = new [10];
        for (var i = 0; i < 10; i++) {
            var angle = (i * 36) - 90; // -90 pour commencer en haut
            var radius = (i % 2 == 0) ? outerRadius : innerRadius;
            var rad = Math.toRadians(angle);
            points[i] = [
                x + (radius * Math.cos(rad)),
                y + (radius * Math.sin(rad))
            ];
        }

        // Dessiner l'étoile remplie (ombre)
        dc.setColor(glowColor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(points);

        // Dessiner l'étoile principale
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(points);

        // Contour de l'étoile pour plus de définition
        dc.setPenWidth(1);
        for (var i = 0; i < 10; i++) {
            var nextI = (i + 1) % 10;
            dc.drawLine(points[i][0], points[i][1],
                       points[nextI][0], points[nextI][1]);
        }
    }

    // Appelé quand l'écran s'éteint (mode économie d'énergie)
    function onEnterSleep() {
        // Peut être utilisé pour désactiver certains éléments
    }

    // Appelé quand l'écran se rallume
    function onExitSleep() {
    }
}
