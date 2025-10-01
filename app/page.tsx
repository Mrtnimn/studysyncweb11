import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { GraduationCap, Users, Video, MessageCircle } from 'lucide-react'

export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-primary/5 via-secondary/5 to-accent/5">
      {/* Header */}
      <header className="flex items-center justify-between p-6">
        <div className="flex items-center gap-2">
          <GraduationCap className="h-8 w-8 text-primary" />
          <h1 className="text-2xl font-bold text-primary">StudySync</h1>
        </div>
        <div className="flex gap-3">
          <Button variant="outline" asChild>
            <Link href="/auth/login">Sign In</Link>
          </Button>
          <Button asChild>
            <Link href="/auth/register">Get Started</Link>
          </Button>
        </div>
      </header>

      {/* Hero Section */}
      <main className="container mx-auto px-6 py-12">
        <div className="text-center max-w-4xl mx-auto">
          <h2 className="text-5xl font-bold text-foreground mb-6">
            Your AI-powered study companion for 
            <span className="text-primary"> focused learning</span>
          </h2>
          <p className="text-xl text-muted-foreground mb-8 leading-relaxed">
            Connect with expert tutors, join collaborative study groups, and enhance your learning 
            experience with real-time video sessions and interactive tools.
          </p>
          
          <div className="flex gap-4 justify-center mb-16">
            <Button size="lg" className="text-lg px-8 py-4" asChild>
              <Link href="/auth/register">Start Learning Free</Link>
            </Button>
            <Button size="lg" variant="outline" className="text-lg px-8 py-4" asChild>
              <Link href="/teacher">Become a Tutor</Link>
            </Button>
          </div>

          {/* Features Grid */}
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 mt-20">
            <FeatureCard 
              icon={<Video className="h-8 w-8 text-primary" />}
              title="HD Video Sessions"
              description="Crystal clear video calls with screen sharing and interactive whiteboards"
            />
            <FeatureCard 
              icon={<Users className="h-8 w-8 text-secondary" />}
              title="Study Groups"
              description="Join collaborative study rooms with students at your level"
            />
            <FeatureCard 
              icon={<MessageCircle className="h-8 w-8 text-accent" />}
              title="Real-time Chat"
              description="Instant messaging with file sharing and dictionary lookups"
            />
            <FeatureCard 
              icon={<GraduationCap className="h-8 w-8 text-primary" />}
              title="Expert Tutors"
              description="Connect with verified tutors in Math, Science, Languages and more"
            />
          </div>
        </div>
      </main>
    </div>
  )
}

function FeatureCard({ icon, title, description }: {
  icon: React.ReactNode
  title: string
  description: string
}) {
  return (
    <div className="bg-white/80 backdrop-blur-sm rounded-xl p-6 border border-border/50 hover:shadow-lg transition-all duration-200">
      <div className="mb-4">{icon}</div>
      <h3 className="font-semibold text-lg mb-2">{title}</h3>
      <p className="text-muted-foreground text-sm leading-relaxed">{description}</p>
    </div>
  )
}