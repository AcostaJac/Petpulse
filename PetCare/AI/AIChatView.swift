import SwiftUI

// MARK: - Árbol de conversación
struct ChatNode: Identifiable {
    var id: String
    var label: String
    var followUps: [ChatNode]
    var isUrgent: Bool = false

    static let root: [ChatNode] = [
        ChatNode(id:"feed", label:"🍽️ Alimentación", followUps:[
            ChatNode(id:"feed_qty",   label:"¿Cuánto debe comer al día?", followUps:[
                ChatNode(id:"feed_fat",  label:"Está subiendo de peso",    followUps:[]),
                ChatNode(id:"feed_no",   label:"No quiere comer",          followUps:[], isUrgent:true)]),
            ChatNode(id:"feed_type",  label:"¿Qué alimento es mejor?",    followUps:[
                ChatNode(id:"feed_dry",  label:"Croquetas vs húmeda",      followUps:[]),
                ChatNode(id:"feed_frt",  label:"¿Puede comer frutas?",     followUps:[])]),
            ChatNode(id:"feed_water", label:"¿Cuánta agua necesita?",      followUps:[]),
        ]),
        ChatNode(id:"vax", label:"💉 Vacunas", followUps:[
            ChatNode(id:"vax_which", label:"¿Cuáles son obligatorias?",   followUps:[
                ChatNode(id:"vax_rab",  label:"¿Cuándo la antirrábica?",  followUps:[]),
                ChatNode(id:"vax_pol",  label:"¿Qué es la polivalente?",  followUps:[])]),
            ChatNode(id:"vax_when",  label:"¿Cada cuánto tiempo?",         followUps:[]),
            ChatNode(id:"vax_age",   label:"¿A qué edad empieza?",         followUps:[]),
        ]),
        ChatNode(id:"ill", label:"🤒 Enfermedades", followUps:[
            ChatNode(id:"ill_cold",  label:"🤧 Gripe / resfriado",         followUps:[
                ChatNode(id:"ill_cold_s", label:"¿Cuáles son los síntomas?",    followUps:[]),
                ChatNode(id:"ill_cold_c", label:"¿Cómo ayudarlo en casa?",      followUps:[])]),
            ChatNode(id:"ill_gast",  label:"🤢 Gastritis / vómito",        followUps:[
                ChatNode(id:"ill_g1",     label:"Vomitó solo una vez",           followUps:[]),
                ChatNode(id:"ill_g2",     label:"Vomita repetidamente",          followUps:[], isUrgent:true)]),
            ChatNode(id:"ill_diar",  label:"💩 Diarrea",                   followUps:[
                ChatNode(id:"ill_d1",     label:"Diarrea leve (un día)",         followUps:[]),
                ChatNode(id:"ill_d2",     label:"Diarrea con sangre",            followUps:[], isUrgent:true)]),
            ChatNode(id:"ill_skin",  label:"🔴 Problemas de piel",         followUps:[
                ChatNode(id:"ill_sk1",    label:"Se rasca constantemente",       followUps:[]),
                ChatNode(id:"ill_sk2",    label:"Heridas o llagas",              followUps:[], isUrgent:true)]),
            ChatNode(id:"ill_eye",   label:"👁️ Ojos / nariz",             followUps:[
                ChatNode(id:"ill_e1",     label:"Ojos llorosos o secreción",     followUps:[]),
                ChatNode(id:"ill_n1",     label:"Nariz seca o muy húmeda",       followUps:[])]),
            ChatNode(id:"ill_let",   label:"😴 Letargia / decaimiento",    followUps:[
                ChatNode(id:"ill_l1",     label:"Duerme más que usual",          followUps:[]),
                ChatNode(id:"ill_l2",     label:"No quiere levantarse ni comer", followUps:[], isUrgent:true)], isUrgent:true),
            ChatNode(id:"ill_limp",  label:"🦶 Cojera / dolor",            followUps:[], isUrgent:true),
            ChatNode(id:"ill_bth",   label:"😮‍💨 Dificultad respiratoria",   followUps:[], isUrgent:true),
        ]),
        ChatNode(id:"care", label:"🛁 Higiene & cuidados", followUps:[
            ChatNode(id:"c_bath",  label:"¿Cada cuándo bañarlo?",          followUps:[
                ChatNode(id:"c_sh",    label:"¿Qué shampoo usar?",          followUps:[]),
                ChatNode(id:"c_dry",   label:"¿Cómo secarlo bien?",         followUps:[])]),
            ChatNode(id:"c_teeth", label:"Cuidado dental",                  followUps:[
                ChatNode(id:"c_br",    label:"¿Cómo cepillarle los dientes?",followUps:[]),
                ChatNode(id:"c_sn",    label:"Snacks dentales",              followUps:[])]),
            ChatNode(id:"c_nails", label:"Corte de uñas",                   followUps:[]),
            ChatNode(id:"c_dep",   label:"Desparasitación",                  followUps:[
                ChatNode(id:"c_int",   label:"Parásitos internos",            followUps:[]),
                ChatNode(id:"c_ext",   label:"Pulgas y garrapatas",           followUps:[])]),
        ]),
        ChatNode(id:"sport", label:"🏃 Ejercicio & juego", followUps:[
            ChatNode(id:"s_walk",  label:"¿Cuántos paseos al día?",         followUps:[
                ChatNode(id:"s_time",  label:"¿Cuánto tiempo cada paseo?",  followUps:[]),
                ChatNode(id:"s_pup",   label:"¿Y si es cachorro?",           followUps:[])]),
            ChatNode(id:"s_toys",  label:"¿Qué juguetes recomiendas?",      followUps:[]),
            ChatNode(id:"s_lazy",  label:"Mi mascota es muy sedentaria",    followUps:[]),
        ]),
    ]
}

struct AIChatView: View {
    @EnvironmentObject var petStore: PetStore
    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var isLoading = false
    @State private var errorMsg = ""
    @State private var currentSuggestions: [ChatNode] = ChatNode.root
    @State private var suggestionLevel = 0
    @State private var showVetButton = false
    @FocusState private var isInputFocused: Bool

    var pet: Pet? { petStore.selectedPet }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let p = pet { petBanner(p) }

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            if messages.isEmpty { welcomeMessage }
                            ForEach(messages) { msg in MessageBubble(message: msg).id(msg.id) }
                            if isLoading { typingIndicator }
                            if !errorMsg.isEmpty { errorCard }
                            if showVetButton { vetUrgentCard }
                            if !currentSuggestions.isEmpty { suggestionsView }
                            Color.clear.frame(height: 8).id("bottom")
                        }
                        .padding(14)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onTapGesture { isInputFocused = false }
                    .onChange(of: messages.count)  { _, _ in withAnimation { proxy.scrollTo("bottom") } }
                    .onChange(of: isLoading)        { _, _ in withAnimation { proxy.scrollTo("bottom") } }
                    .onChange(of: showVetButton)    { _, _ in withAnimation { proxy.scrollTo("bottom") } }
                    .onChange(of: currentSuggestions.count) { _, _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation { proxy.scrollTo("bottom") }
                        }
                    }
                }

                inputBar
            }
            .background(Color.bgPage)
            .navigationTitle("Chat IA")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Pet banner
    private func petBanner(_ p: Pet) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle().fill(Color.primaryLight).frame(width: 32, height: 32)
                Text(p.species.emoji).font(.system(size: 16))
            }
            VStack(alignment: .leading, spacing: 1) {
                Text("Analizando el perfil de \(p.name)").font(.system(size: 12, weight: .medium))
                Text("\(p.species.rawValue) · \(p.breed) · \(Int(p.ageYears)) años").font(.system(size: 10)).foregroundColor(.textMuted)
            }
            Spacer()
            ZStack {
                Circle().fill(Color.primaryLight).frame(width: 28, height: 28)
                Image(systemName: "cpu.fill").font(.system(size: 12)).foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .background(Color.white).overlay(Divider(), alignment: .bottom)
    }

    private var welcomeMessage: some View {
        HStack(alignment: .top, spacing: 8) {
            botAvatar
            MessageBubbleContent(
                text: "¡Hola! Soy PetAssistant 🐾\nElige un tema y te guiaré paso a paso. Ante síntomas graves, te recomendaré un veterinario.",
                isUser: false)
        }
    }

    private var botAvatar: some View {
        ZStack {
            Circle().fill(Color.primaryLight).frame(width: 28, height: 28)
            Image(systemName: "cpu.fill").font(.system(size: 12)).foregroundColor(.primary)
        }
    }

    private var typingIndicator: some View {
        HStack(alignment: .top, spacing: 8) {
            botAvatar
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Circle().fill(Color.textHint).frame(width: 7, height: 7)
                        .scaleEffect(isLoading ? 1.0 : 0.6)
                        .animation(.easeInOut(duration: 0.5).repeatForever().delay(Double(i)*0.15), value: isLoading)
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(Color.white).cornerRadius(14)
        }
    }

    private var errorCard: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle").font(.system(size: 12)).foregroundColor(.coral)
            Text(errorMsg).font(.system(size: 11)).foregroundColor(.coral)
            Spacer()
            Button("Reintentar") { errorMsg = "" }.font(.system(size: 11, weight: .medium)).foregroundColor(.primary)
        }
        .padding(10).background(Color.coralLight).cornerRadius(10)
    }

    // MARK: - Botón urgente veterinario
    private var vetUrgentCard: some View {
        HStack(alignment: .top, spacing: 8) {
            botAvatar
            VStack(alignment: .leading, spacing: 8) {
                Text("⚠️ Por principios éticos y responsabilidad profesional, no puedo emitir un diagnóstico médico. Lo que describes podría requerir atención veterinaria. Por favor consulta a un profesional.")
                    .font(.system(size: 12)).lineSpacing(3)
                    .padding(12)
                    .background(Color(hex: "FFF3CD")).foregroundColor(Color(hex: "856404"))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "FFEAA7"), lineWidth: 1))

                Button {
                    isInputFocused = false
                    petStore.selectedTab = 2
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "cross.case.fill").font(.system(size: 14))
                        Text("Ver veterinarios disponibles")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.white).frame(maxWidth: .infinity)
                    .padding(.vertical, 12).background(Color.coral).cornerRadius(12)
                }
            }
        }
    }

    // MARK: - Sugerencias dinámicas
    private var suggestionsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 5) {
                Image(systemName: "lightbulb.fill").font(.system(size: 10)).foregroundColor(.gold)
                Text(suggestionLevel == 0 ? "¿Sobre qué necesitas ayuda?" : "Cuéntame más:")
                    .font(.system(size: 11, weight: .medium)).foregroundColor(.textMuted)
            }
            FlowLayout(spacing: 6) {
                ForEach(currentSuggestions) { node in
                    Button {
                        send(node.label, next: node.followUps, urgent: node.isUrgent)
                    } label: {
                        HStack(spacing: 4) {
                            if node.isUrgent {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 9)).foregroundColor(.coral)
                            }
                            Text(node.label).font(.system(size: 11, weight: .medium))
                        }
                        .padding(.horizontal, 11).padding(.vertical, 7)
                        .background(node.isUrgent ? Color.coralLight : Color.white)
                        .foregroundColor(node.isUrgent ? .coral : .primary)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16)
                            .stroke(node.isUrgent ? Color.coral : Color.primary, lineWidth: 1))
                    }
                }
                if suggestionLevel > 0 {
                    Button {
                        currentSuggestions = ChatNode.root
                        suggestionLevel = 0
                        showVetButton = false
                    } label: {
                        Text("↩ Inicio").font(.system(size: 11)).foregroundColor(.textMuted)
                            .padding(.horizontal, 11).padding(.vertical, 7)
                            .background(Color(white: 0.93)).cornerRadius(16)
                    }
                }
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Input bar
    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField("Pregunta sobre \(pet?.name ?? "tu mascota")…", text: $inputText, axis: .vertical)
                .font(.system(size: 13)).lineLimit(1...4)
                .padding(.horizontal, 14).padding(.vertical, 9)
                .background(Color(white: 0.96)).cornerRadius(20)
                .focused($isInputFocused)
                .submitLabel(.send)
                .onSubmit {
                    if !inputText.trimmingCharacters(in: .whitespaces).isEmpty {
                        send(inputText, next: [], urgent: false)
                    }
                }

            Button {
                send(inputText, next: [], urgent: false)
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                    .frame(width: 34, height: 34)
                    .background(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.textHint : Color.primary)
                    .clipShape(Circle())
            }
            .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(Color.white)
        .overlay(Divider(), alignment: .top)
    }

    // MARK: - Send
    private func send(_ text: String, next: [ChatNode], urgent: Bool) {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        inputText = ""
        errorMsg = ""
        isInputFocused = false
        messages.append(ChatMessage(content: trimmed, isUser: true))
        isLoading = true
        showVetButton = false

        if !next.isEmpty {
            currentSuggestions = next; suggestionLevel += 1
        } else {
            currentSuggestions = []
        }

        Task {
            do {
                let ctx = pet?.geminiContext ?? "Sin mascota"
                let response = try await GeminiService.shared.sendMessage(
                    userMessage: trimmed, petContext: ctx, history: messages.dropLast()
                )
                await MainActor.run {
                    messages.append(ChatMessage(content: response, isUser: false))
                    isLoading = false
                    if urgent { showVetButton = true }
                    if currentSuggestions.isEmpty {
                        currentSuggestions = ChatNode.root; suggestionLevel = 0
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMsg = error.localizedDescription
                    if currentSuggestions.isEmpty {
                        currentSuggestions = ChatNode.root; suggestionLevel = 0
                    }
                }
            }
        }
    }
}

// MARK: - MessageBubble
struct MessageBubble: View {
    let message: ChatMessage
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if !message.isUser {
                ZStack {
                    Circle().fill(Color.primaryLight).frame(width: 28, height: 28)
                    Image(systemName: "cpu.fill").font(.system(size: 12)).foregroundColor(.primary)
                }
            }
            MessageBubbleContent(text: message.content, isUser: message.isUser)
            if message.isUser { Spacer(minLength: 40) }
        }
        .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
    }
}

struct MessageBubbleContent: View {
    let text: String
    let isUser: Bool
    var body: some View {
        Text(text).font(.system(size: 13))
            .foregroundColor(isUser ? .white : Color(white: 0.12))
            .padding(.horizontal, 13).padding(.vertical, 9)
            .background(isUser ? Color.primary : Color.white)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
            .frame(maxWidth: 260, alignment: isUser ? .trailing : .leading)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let w = proposal.width ?? 0; var h: CGFloat = 0; var x: CGFloat = 0; var lh: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > w && x > 0 { x = 0; h += lh + spacing; lh = 0 }
            x += s.width + spacing; lh = max(lh, s.height)
        }
        return CGSize(width: w, height: h + lh)
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX; var y = bounds.minY; var lh: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > bounds.maxX && x > bounds.minX { x = bounds.minX; y += lh + spacing; lh = 0 }
            v.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(s))
            x += s.width + spacing; lh = max(lh, s.height)
        }
    }
}
