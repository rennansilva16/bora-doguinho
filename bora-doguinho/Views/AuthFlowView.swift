import SwiftUI

struct AuthFlowView: View {
    @EnvironmentObject private var session: AuthSessionStore
    @State private var destination: Destination = .login

    enum Destination { case login, signUp, resetPassword }

    var body: some View {
        NavigationStack {
            Group {
                switch destination {
                case .login:
                    LoginView(showSignUp: { destination = .signUp }, showReset: { destination = .resetPassword })
                case .signUp:
                    RegistrationView(backToLogin: { destination = .login })
                case .resetPassword:
                    PasswordRecoveryView(backToLogin: { destination = .login })
                }
            }
        }
        .alert("Não foi possível concluir", isPresented: Binding(
            get: { session.errorMessage != nil },
            set: { if !$0 { session.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { session.errorMessage = nil }
        } message: {
            Text(session.errorMessage ?? "")
        }
    }
}

struct LoginView: View {
    @EnvironmentObject private var session: AuthSessionStore
    let showSignUp: () -> Void
    let showReset: () -> Void
    @State private var email = ""
    @State private var password = ""
    @State private var isSubmitting = false

    var body: some View {
        AuthForm(title: "Bora, Doguinho!", subtitle: "Entre para encontrar seu doguinho.") {
            TextField("E-mail", text: $email).textInputAutocapitalization(.never).keyboardType(.emailAddress).textFieldStyle(.roundedBorder)
            SecureField("Senha", text: $password).textFieldStyle(.roundedBorder)
            Button("Entrar") { submit() }.buttonStyle(.borderedProminent).disabled(isSubmitting || email.isEmpty || password.isEmpty)
            Button("Esqueci minha senha", action: showReset).buttonStyle(.plain)
            Divider()
            Button("Criar conta", action: showSignUp)
        }
    }

    private func submit() {
        isSubmitting = true
        Task {
            _ = await session.signIn(email: email, password: password)
            isSubmitting = false
        }
    }
}

struct RegistrationView: View {
    @EnvironmentObject private var session: AuthSessionStore
    let backToLogin: () -> Void
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmation = ""
    @State private var isSubmitting = false
    @State private var validationMessage: String?

    var body: some View {
        AuthForm(title: "Criar conta", subtitle: "Harry e Pandora estarão esperando por você.") {
            TextField("Nome", text: $name).textFieldStyle(.roundedBorder)
            TextField("E-mail", text: $email).textInputAutocapitalization(.never).keyboardType(.emailAddress).textFieldStyle(.roundedBorder)
            SecureField("Senha (mínimo de 6 caracteres)", text: $password).textFieldStyle(.roundedBorder)
            SecureField("Confirmar senha", text: $confirmation).textFieldStyle(.roundedBorder)
            Button("Cadastrar") { submit() }.buttonStyle(.borderedProminent).disabled(isSubmitting)
            Button("Já tenho uma conta", action: backToLogin).buttonStyle(.plain)
        }
        .alert("Confira os dados", isPresented: Binding(get: { validationMessage != nil }, set: { if !$0 { validationMessage = nil } })) {
            Button("OK", role: .cancel) { validationMessage = nil }
        } message: { Text(validationMessage ?? "") }
    }

    private func submit() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { validationMessage = "Informe seu nome."; return }
        guard password.count >= 6 else { validationMessage = "A senha deve ter pelo menos 6 caracteres."; return }
        guard password == confirmation else { validationMessage = "A confirmação de senha não confere."; return }
        isSubmitting = true
        Task {
            _ = await session.signUp(name: name, email: email, password: password)
            isSubmitting = false
        }
    }
}

struct PasswordRecoveryView: View {
    @EnvironmentObject private var session: AuthSessionStore
    let backToLogin: () -> Void
    @State private var email = ""
    @State private var isSubmitting = false
    @State private var didSend = false

    var body: some View {
        AuthForm(title: "Recuperar senha", subtitle: "Enviaremos um link para o seu e-mail.") {
            TextField("E-mail", text: $email).textInputAutocapitalization(.never).keyboardType(.emailAddress).textFieldStyle(.roundedBorder)
            Button("Enviar link") { submit() }.buttonStyle(.borderedProminent).disabled(isSubmitting || email.isEmpty)
            Button("Voltar ao login", action: backToLogin).buttonStyle(.plain)
        }
        .alert("E-mail enviado", isPresented: $didSend) { Button("OK", role: .cancel) {} } message: { Text("Confira sua caixa de entrada para redefinir a senha.") }
    }

    private func submit() {
        isSubmitting = true
        Task {
            didSend = await session.sendPasswordReset(to: email)
            isSubmitting = false
        }
    }
}

private struct AuthForm<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            Image(systemName: "pawprint.fill").font(.system(size: 52)).foregroundStyle(.pink)
            Text(title).font(.largeTitle.bold())
            Text(subtitle).foregroundStyle(.secondary).multilineTextAlignment(.center)
            VStack(spacing: 12, content: { content }).padding(.top, 16)
            Spacer()
        }
        .padding(32)
    }
}
