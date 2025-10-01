// Environment Variable Validation
// Ensures all required environment variables are present and provides helpful error messages

interface EnvironmentConfig {
  supabaseUrl: string
  supabaseAnonKey: string
  supabaseServiceRoleKey?: string
  appUrl: string
}

class EnvironmentValidator {
  private static instance: EnvironmentValidator
  private config: EnvironmentConfig | null = null
  private validationErrors: string[] = []

  private constructor() {
    this.validate()
  }

  static getInstance(): EnvironmentValidator {
    if (!EnvironmentValidator.instance) {
      EnvironmentValidator.instance = new EnvironmentValidator()
    }
    return EnvironmentValidator.instance
  }

  private validate() {
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
    const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
    const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY
    const appUrl = process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:5000'

    if (!supabaseUrl) {
      this.validationErrors.push('NEXT_PUBLIC_SUPABASE_URL is missing')
    }

    if (!supabaseAnonKey) {
      this.validationErrors.push('NEXT_PUBLIC_SUPABASE_ANON_KEY is missing')
    }

    if (supabaseUrl && !supabaseUrl.includes('supabase.co')) {
      this.validationErrors.push('NEXT_PUBLIC_SUPABASE_URL appears to be invalid')
    }

    if (this.validationErrors.length === 0 && supabaseUrl && supabaseAnonKey) {
      this.config = {
        supabaseUrl,
        supabaseAnonKey,
        supabaseServiceRoleKey,
        appUrl,
      }
    }
  }

  isValid(): boolean {
    return this.config !== null && this.validationErrors.length === 0
  }

  getConfig(): EnvironmentConfig {
    if (!this.config) {
      throw new Error(
        `Environment configuration is invalid:\n${this.validationErrors.join('\n')}`
      )
    }
    return this.config
  }

  getErrors(): string[] {
    return this.validationErrors
  }

  hasSupabase(): boolean {
    return !!(this.config?.supabaseUrl && this.config?.supabaseAnonKey)
  }
}

export const envValidator = EnvironmentValidator.getInstance()

export function validateEnvironment(): boolean {
  return envValidator.isValid()
}

export function getEnvironmentConfig(): EnvironmentConfig {
  return envValidator.getConfig()
}

export function getEnvironmentErrors(): string[] {
  return envValidator.getErrors()
}
