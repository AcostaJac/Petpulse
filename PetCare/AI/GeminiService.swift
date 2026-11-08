import Foundation

class GeminiService {
    static let shared = GeminiService()

    func sendMessage(userMessage: String, petContext: String, history: [ChatMessage]) async throws -> String {
        try await Task.sleep(nanoseconds: 900_000_000)
        return LocalVetAI.respond(to: userMessage, context: petContext)
    }
}

struct LocalVetAI {
    static func respond(to message: String, context: String) -> String {
        let msg = message.lowercased()
        let name = extractName(from: context)
        let species = extractSpecies(from: context)

        if contains(msg, ["vacuna","vacunas","antirrábic","polivalente","bordetella"]) {
            switch species {
            case "perro": return "Para \(name) las vacunas esenciales son: antirrábica (anual), polivalente DHPP (cada 3 años después de la primera) y bordetella si convive con otros perros 🐶💉. Te recomiendo visitar al veterinario para actualizar la cartilla."
            case "gato":  return "Las vacunas principales para \(name) son la triple felina (anual) y antirrábica (anual) 🐱💉. Si sale al exterior, también se recomienda la vacuna contra leucemia felina. Consulta con tu veterinario."
            default:       return "Las vacunas de \(name) dependen de su especie y edad 💉. Consulta con tu veterinario para un calendario personalizado. ¡Mantenerlas al día es clave! 🐾"
            }
        }

        if contains(msg, ["comer","comida","aliment","dieta","croqueta","hambre","agua"]) {
            switch species {
            case "perro": return "Para \(name) lo ideal son 2 comidas al día (mañana y noche) 🍽️🐶. La cantidad depende del peso — entre 1.5 y 3 tazas de croqueta de buena calidad. ¡Siempre con agua fresca disponible! 💧"
            case "gato":  return "Los gatos como \(name) prefieren varias porciones pequeñas al día 🐱🍽️. Combina croquetas premium con alimento húmedo para hidratarlo mejor. Evita la leche de vaca."
            default:       return "Una dieta balanceada es esencial para \(name) 🍽️. Usa alimento específico para su especie. Tu veterinario puede indicar la cantidad exacta según su peso. 🐾"
            }
        }

        if contains(msg, ["gripe","resfriado","estornud","secreción nasal","moquillo"]) {
            return "Los síntomas de gripe en \(name) pueden incluir: estornudos, secreción nasal, ojos llorosos y falta de energía 🤧. En casos leves, asegúrate de que esté abrigado y bien hidratado. Si los síntomas persisten más de 2 días o empeoran, es importante acudir al veterinario. 🏥"
        }

        if contains(msg, ["gastritis","vomit","náuseas"]) {
            if contains(msg, ["repetid","much","vari","sangr","no para"]) {
                return "Vómitos repetitivos pueden indicar algo serio en \(name) ⚠️. Por principios éticos y responsabilidad profesional, no puedo emitir un diagnóstico. Lo que describes podría requerir atención veterinaria urgente. Por favor consulta a un profesional lo antes posible. 🏥"
            }
            return "Si \(name) vomitó una sola vez, puede ser algo pasajero 🤢. Retira el alimento por 4-6 horas, ofrece pequeñas cantidades de agua y observa su comportamiento. Si vomita más de 2 veces o se ve decaído, visita al veterinario."
        }

        if contains(msg, ["diarrea"]) {
            if contains(msg, ["sangr","negra","mucha","no para"]) {
                return "La diarrea con sangre en \(name) es una señal de alarma ⚠️. Por principios éticos y responsabilidad profesional, no puedo emitir un diagnóstico. Esto requiere atención veterinaria urgente. Por favor busca un veterinario de inmediato. 🏥"
            }
            return "Para la diarrea leve de \(name), ofrece agua en pequeñas cantidades frecuentes y alimento blando (arroz cocido con pollo sin sal) 💩. Si dura más de 24 horas o hay sangre, consulta al veterinario inmediatamente."
        }

        if contains(msg, ["letargia","decaíd","triste","no se mueve","no quiere levantarse","cansad"]) {
            return "La letargia prolongada en \(name) puede ser señal de algo más serio 😴⚠️. Por principios éticos y responsabilidad profesional, no puedo emitir un diagnóstico. Si \(name) lleva más de 24 horas sin energía y sin comer, es importante visitar al veterinario. 🏥"
        }

        if contains(msg, ["cojea","dolor","pata","no camina","se lastimó"]) {
            return "La cojera o dolor al caminar en \(name) requiere evaluación profesional ⚠️. Por principios éticos y responsabilidad profesional, no puedo emitir un diagnóstico. Por favor lleva a \(name) al veterinario para un examen completo. 🏥"
        }

        if contains(msg, ["respira","ahog","jadeante","no puede respirar"]) {
            return "¡La dificultad para respirar es una emergencia! ⚠️🚨 Lleva a \(name) al veterinario de inmediato. No esperes. Por principios éticos y responsabilidad profesional, no puedo emitir un diagnóstico — este síntoma requiere atención urgente. 🏥"
        }

        if contains(msg, ["rasca","picazón","alergia","piel","granito","erupción"]) {
            return "El rascado frecuente en \(name) puede deberse a pulgas, alergias o problemas de piel 🔴. Revisa si tiene parásitos visibles. Si el rascado es intenso o hay heridas, el veterinario puede hacer pruebas de alergia. 🐾"
        }

        if contains(msg, ["bañar","baño","shampoo","higiene","pelaje","cepillar"]) {
            switch species {
            case "perro": return "\(name) debe bañarse cada 3-4 semanas con shampoo especial para perros 🛁🐶. Cepilla su pelo 2-3 veces por semana para evitar enredos. ¡Un pelaje limpio es señal de buena salud! ✨"
            case "gato":  return "Los gatos como \(name) se asean solos 🐱✨. Solo necesita baño si se ensucia mucho. Cepíllalo regularmente para evitar bolas de pelo. 🪮"
            default:       return "La higiene de \(name) es importante 🛁. La frecuencia depende de su especie — consulta con tu veterinario o groomer. 🐾"
            }
        }

        if contains(msg, ["desparasit","pulga","garrapata","parásito"]) {
            return "La desparasitación de \(name) debe hacerse cada 3 meses para parásitos internos, y mensualmente para pulgas y garrapatas 💊🐾. Pregúntale a tu veterinario el mejor producto según su peso y especie."
        }

        if contains(msg, ["ejercicio","paseo","caminar","correr","jugar","actividad"]) {
            switch species {
            case "perro": return "\(name) necesita al menos 2 paseos diarios de 20-30 minutos 🚶‍♂️🐶. ¡El ejercicio es excelente para su salud física y mental! 🎾"
            case "gato":  return "Los gatos como \(name) necesitan estimulación con juguetes interactivos 🐱🎣. Dedica 15 min diarios a jugar — reduce el estrés y mantiene su peso ideal. ✨"
            default:       return "\(name) necesita actividad física regular 🏃. El tipo y duración depende de su especie — consulta con tu veterinario. 🐾"
            }
        }

        if contains(msg, ["diente","boca","dental","aliento","encia"]) {
            return "La salud dental de \(name) es muy importante 🦷. Cepilla sus dientes 2-3 veces por semana con pasta especial para mascotas. También hay snacks dentales que ayudan. ¡Una boca sana es una mascota sana! 😊"
        }

        if contains(msg, ["peso","gordo","obeso","delgado","subió","bajó"]) {
            return "El peso saludable de \(name) depende de su raza y edad 📊. Lo ideal es poder sentir sus costillas sin verlas. Si hay cambios bruscos, visita al veterinario para descartar problemas de salud. 🏥"
        }

        let generales = [
            "Estoy aquí para ayudarte con el cuidado de \(name) 🐾. Elige un tema de los botones de abajo para que te guíe paso a paso. Ante síntomas graves, siempre recomienda visitar al veterinario. 🏥",
            "¡Qué bien que te preocupas por \(name)! 💙 Para darte la mejor orientación, selecciona una de las opciones disponibles. Ante cualquier duda médica seria, tu veterinario es el mejor aliado. 🐾",
            "El bienestar de \(name) es mi prioridad 🐾❤️. Puedo orientarte sobre alimentación, vacunas, higiene y ejercicio. Para diagnósticos médicos, siempre consulta al veterinario. 😊"
        ]
        return generales[Int.random(in: 0..<generales.count)]
    }

    private static func contains(_ text: String, _ keywords: [String]) -> Bool {
        keywords.contains { text.contains($0) }
    }
    private static func extractName(from context: String) -> String {
        for part in context.components(separatedBy: ",") {
            if part.lowercased().contains("nombre:") {
                return part.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespaces) ?? "tu mascota"
            }
        }
        return "tu mascota"
    }
    private static func extractSpecies(from context: String) -> String {
        let c = context.lowercased()
        if c.contains("perro")||c.contains("labrador")||c.contains("golden")||c.contains("bulldog") { return "perro" }
        if c.contains("gato")||c.contains("felino") { return "gato" }
        if c.contains("conejo") { return "conejo" }
        return "otro"
    }
}

enum GeminiError: LocalizedError {
    case invalidURL, invalidResponse, parsingError, invalidAPIKey, rateLimitExceeded
    case serverError(Int)
    var errorDescription: String? {
        switch self {
        case .invalidURL:         return "URL inválida"
        case .invalidResponse:    return "Respuesta inválida"
        case .parsingError:       return "Error al procesar respuesta"
        case .invalidAPIKey:      return "API Key inválida"
        case .rateLimitExceeded:  return "Espera unos segundos e intenta de nuevo 😊"
        case .serverError(let c): return "Error del servidor: \(c)"
        }
    }
}

extension Pet {
    var geminiContext: String {
        "Nombre: \(name), Especie: \(species.rawValue) (\(breed)), Edad: \(Int(ageYears)) años, Peso: \(String(format:"%.1f",weight))kg, Género: \(gender.rawValue), Esterilizado: \(sterilized ? "Sí":"No"), Alergias: \(allergies)"
    }
}
