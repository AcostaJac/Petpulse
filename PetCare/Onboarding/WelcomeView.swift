import SwiftUI

// MARK: - Auth Root
struct AuthRootView: View {
    @State private var mode: AuthMode = .welcome
    @State private var pendingEmail = ""
    enum AuthMode { case welcome, login, register, verify }

    var body: some View {
        switch mode {
        case .welcome:  WelcomeView(onLogin: { mode = .login }, onRegister: { mode = .register })
        case .login:    LoginView(onBack: { mode = .welcome }, onRegister: { mode = .register })
        case .register: RegisterView(onBack: { mode = .welcome }, onVerify: { email in pendingEmail = email; mode = .verify })
        case .verify:   VerifyView(email: pendingEmail, onBack: { mode = .register })
        }
    }
}

// MARK: - Welcome
struct WelcomeView: View {
    let onLogin: () -> Void
    let onRegister: () -> Void

    var body: some View {
        ZStack {
            Color(hex: "F0FBF6").ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                AppLogoView(size: 100)
                Spacer().frame(height: 16)
                Text("El bienestar de tu mascota,\nsiempre contigo")
                    .font(.system(size: 16)).foregroundColor(.textMuted)
                    .multilineTextAlignment(.center).lineSpacing(4)
                Spacer().frame(height: 32)
                HStack(spacing: 8) {
                    ForEach(["🐶 Perros","🐱 Gatos","🐰 Conejos","🦜 Aves"], id: \.self) { s in
                        Text(s).font(.system(size: 11, weight: .medium))
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Color.primaryLight).foregroundColor(.green).cornerRadius(20)
                    }
                }
                Spacer()
                VStack(spacing: 12) {
                    Button(action: onRegister) {
                        Text("Crear cuenta gratis")
                            .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 15)
                            .background(Color.primary).cornerRadius(14)
                    }
                    Button(action: onLogin) {
                        Text("Ya tengo cuenta")
                            .font(.system(size: 15, weight: .medium)).foregroundColor(.primary)
                            .frame(maxWidth: .infinity).padding(.vertical, 14)
                            .background(Color.white).cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.primary, lineWidth: 1.5))
                    }
                }
                .padding(.horizontal, 28)
                Text("Al continuar aceptas nuestros Términos y Política de Privacidad")
                    .font(.system(size: 11)).foregroundColor(.textHint)
                    .multilineTextAlignment(.center).padding(.top, 12)
                Spacer().frame(height: 40)
            }
        }
    }
}

// MARK: - Login
struct LoginView: View {
    @EnvironmentObject var petStore: PetStore
    let onBack: () -> Void
    let onRegister: () -> Void
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var errorMsg = ""
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Color(hex: "F0FBF6").ignoresSafeArea()
            VStack(spacing: 0) {
                authNavBar(onBack: onBack)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer().frame(height: 28)
                        Text("Bienvenido de vuelta 👋")
                            .font(.system(size: 26, weight: .bold)).foregroundColor(.primary)
                        Text("Inicia sesión para cuidar a tu mascota")
                            .font(.system(size: 14)).foregroundColor(.textMuted).padding(.top, 4)
                        Spacer().frame(height: 32)
                        authField("Correo electrónico", text: $email, icon: "envelope", keyboard: .emailAddress)
                        Spacer().frame(height: 14)
                        passwordFieldView(label: "Contraseña", text: $password, show: $showPassword)
                        if !errorMsg.isEmpty { errorBadge(errorMsg) }
                        Spacer().frame(height: 28)
                        loadingButton("Iniciar sesión", loading: isLoading, action: doLogin)
                        Spacer().frame(height: 24)
                        HStack {
                            Spacer()
                            Text("¿No tienes cuenta? ").font(.system(size: 14)).foregroundColor(.textMuted)
                            Button("Regístrate", action: onRegister).font(.system(size: 14, weight: .semibold)).foregroundColor(.primary)
                            Spacer()
                        }
                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal, 28)
                }
            }
        }
    }

    private func doLogin() {
        isLoading = true; errorMsg = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let (ok, msg) = petStore.login(email: email, password: password)
            if !ok { errorMsg = msg }
            isLoading = false
        }
    }
}

// MARK: - Register
struct RegisterView: View {
    @EnvironmentObject var petStore: PetStore
    let onBack: () -> Void
    let onVerify: (String) -> Void
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var errorMsg = ""
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Color(hex: "F0FBF6").ignoresSafeArea()
            VStack(spacing: 0) {
                authNavBar(onBack: onBack)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer().frame(height: 28)
                        Text("Crear cuenta 🐾")
                            .font(.system(size: 26, weight: .bold)).foregroundColor(.primary)
                        Text("Únete y cuida mejor a tu mascota")
                            .font(.system(size: 14)).foregroundColor(.textMuted).padding(.top, 4)
                        Spacer().frame(height: 28)
                        authField("Nombre completo", text: $name, icon: "person", keyboard: .default)
                        Spacer().frame(height: 14)
                        authField("Correo electrónico", text: $email, icon: "envelope", keyboard: .emailAddress)
                        Spacer().frame(height: 14)
                        passwordFieldView(label: "Contraseña", text: $password, show: $showPassword)
                        Spacer().frame(height: 14)
                        passwordFieldView(label: "Confirmar contraseña", text: $confirmPassword, show: $showPassword)
                        if !errorMsg.isEmpty { errorBadge(errorMsg) }
                        Spacer().frame(height: 28)
                        loadingButton("Crear cuenta", loading: isLoading, action: doRegister)
                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal, 28)
                }
            }
        }
    }

    private func doRegister() {
        errorMsg = ""
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { errorMsg = "Ingresa tu nombre."; return }
        guard email.contains("@") && email.contains(".") else { errorMsg = "Ingresa un correo válido."; return }
        guard password.count >= 6 else { errorMsg = "La contraseña debe tener al menos 6 caracteres."; return }
        guard password == confirmPassword else { errorMsg = "Las contraseñas no coinciden."; return }
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            let (ok, msg) = petStore.register(name: name, email: email, password: password)
            isLoading = false
            if ok { onVerify(email) } else { errorMsg = msg }
        }
    }
}

// MARK: - Verify Email
struct VerifyView: View {
    @EnvironmentObject var petStore: PetStore
    let email: String
    let onBack: () -> Void
    @State private var code = ""
    @State private var errorMsg = ""
    @State private var isLoading = false
    @State private var codeSent = false
    @State private var isSending = false

    var body: some View {
        ZStack {
            Color(hex: "F0FBF6").ignoresSafeArea()
            VStack(spacing: 0) {
                authNavBar(onBack: onBack)
                VStack(spacing: 0) {
                    Spacer()
                    Text("📧").font(.system(size: 60))
                    Spacer().frame(height: 20)
                    Text("Verifica tu correo").font(.system(size: 26, weight: .bold)).foregroundColor(.primary)
                    Text("Ingresa el código de 6 dígitos\nque enviamos a \(email)")
                        .font(.system(size: 14)).foregroundColor(.textMuted)
                        .multilineTextAlignment(.center).lineSpacing(4).padding(.top, 8)
                    Spacer().frame(height: 28)

                    // Botón enviar código
                    if !codeSent {
                        Button {
                            isSending = true
                            // Simula envío al correo (internamente el código siempre es 123456)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                isSending = false
                                codeSent = true
                            }
                        } label: {
                            HStack(spacing: 8) {
                                if isSending {
                                    ProgressView().tint(.white).scaleEffect(0.8)
                                } else {
                                    Image(systemName: "envelope.fill").font(.system(size: 14))
                                }
                                Text(isSending ? "Enviando..." : "Enviar código al correo")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 15)
                            .background(Color.primary).cornerRadius(14)
                        }
                        .disabled(isSending)
                        .padding(.horizontal, 28)
                    } else {
                        // Confirmación de envío
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.primary)
                            Text("Código enviado a \(email)").font(.system(size: 13)).foregroundColor(.textMuted)
                        }
                        .padding(.bottom, 20)

                        // Campo para ingresar código
                        TextField("• • • • • •", text: $code)
                            .font(.system(size: 34, weight: .bold, design: .monospaced))
                            .multilineTextAlignment(.center).keyboardType(.numberPad)
                            .padding(.vertical, 16)
                            .background(Color.white).cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(code.isEmpty ? Color.cardBorder : Color.primary, lineWidth: 1.5))
                            .padding(.horizontal, 50)
                            .onChange(of: code) { _, new in if new.count > 6 { code = String(new.prefix(6)) } }

                        if !errorMsg.isEmpty {
                            Text(errorMsg).font(.system(size: 12)).foregroundColor(.coral).padding(.top, 8)
                        }

                        Spacer().frame(height: 24)
                        Button(action: doVerify) {
                            Group {
                                if isLoading { ProgressView().tint(.white) }
                                else { Text("Verificar y continuar").font(.system(size: 16, weight: .semibold)).foregroundColor(.white) }
                            }
                            .frame(maxWidth: .infinity).padding(.vertical, 15)
                            .background(code.count == 6 ? Color.primary : Color.textHint).cornerRadius(14)
                        }
                        .disabled(code.count != 6 || isLoading)
                        .padding(.horizontal, 28)

                        Button {
                            code = ""; errorMsg = ""
                            isSending = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { isSending = false }
                        } label: {
                            Text(isSending ? "Reenviando..." : "¿No llegó? Reenviar código")
                                .font(.system(size: 13)).foregroundColor(.primary).padding(.top, 12)
                        }
                        .disabled(isSending)
                    }
                    Spacer()
                }
            }
        }
    }

    private func doVerify() {
        isLoading = true; errorMsg = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !petStore.verifyCode(code, email: email) {
                errorMsg = "Código incorrecto. El código es de 6 dígitos."
            }
            isLoading = false
        }
    }
}

// MARK: - Shared helpers
func authNavBar(onBack: @escaping () -> Void) -> some View {
    HStack {
        Button(action: onBack) {
            Image(systemName: "chevron.left").font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary).padding(10)
                .background(Color.white).clipShape(Circle())
                .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        }
        Spacer()
        AppIconView(size: 38)
        Spacer()
        Color.clear.frame(width: 44)
    }
    .padding(.horizontal, 20).padding(.top, 16)
}

func authField(_ label: String, text: Binding<String>, icon: String, keyboard: UIKeyboardType) -> some View {
    VStack(alignment: .leading, spacing: 5) {
        Text(label).font(.system(size: 12, weight: .medium)).foregroundColor(.textMuted)
        HStack(spacing: 10) {
            Image(systemName: icon).font(.system(size: 14)).foregroundColor(.textMuted).frame(width: 20)
            TextField(label, text: text)
                .font(.system(size: 14)).keyboardType(keyboard)
                .autocorrectionDisabled().textInputAutocapitalization(.never)
        }
        .padding(.horizontal, 14).padding(.vertical, 13)
        .background(Color.white).cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 0.5))
    }
}

func passwordFieldView(label: String, text: Binding<String>, show: Binding<Bool>) -> some View {
    VStack(alignment: .leading, spacing: 5) {
        Text(label).font(.system(size: 12, weight: .medium)).foregroundColor(.textMuted)
        HStack {
            Group {
                if show.wrappedValue { TextField("••••••••", text: text) }
                else { SecureField("••••••••", text: text) }
            }
            .font(.system(size: 14)).autocorrectionDisabled()
            Button { show.wrappedValue.toggle() } label: {
                Image(systemName: show.wrappedValue ? "eye.slash" : "eye").foregroundColor(.textMuted)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 13)
        .background(Color.white).cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 0.5))
    }
}

func errorBadge(_ msg: String) -> some View {
    HStack(spacing: 6) {
        Image(systemName: "exclamationmark.circle.fill").font(.system(size: 13)).foregroundColor(.coral)
        Text(msg).font(.system(size: 12)).foregroundColor(.coral)
    }
    .padding(10).background(Color.coralLight).cornerRadius(10).padding(.top, 8)
}

func loadingButton(_ title: String, loading: Bool, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Group {
            if loading { ProgressView().tint(.white) }
            else { Text(title).font(.system(size: 16, weight: .semibold)).foregroundColor(.white) }
        }
        .frame(maxWidth: .infinity).padding(.vertical, 15)
        .background(Color.primary).cornerRadius(14)
    }
    .disabled(loading)
}
