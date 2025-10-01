'use client'

import { useEffect, useState } from 'react'
import { AlertCircle, CheckCircle, ExternalLink } from 'lucide-react'
import { Card, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { getDatabaseStatus, type DatabaseStatus } from '@/lib/utils/database-setup'

export function DatabaseStatusBanner() {
  const [status, setStatus] = useState<DatabaseStatus | null>(null)
  const [loading, setLoading] = useState(true)
  const [dismissed, setDismissed] = useState(false)

  useEffect(() => {
    checkStatus()
  }, [])

  const checkStatus = async () => {
    try {
      const dbStatus = await getDatabaseStatus()
      setStatus(dbStatus)
      
      if (dbStatus.isReady) {
        setDismissed(true)
      }
    } catch (error) {
      console.error('Failed to check database status:', error)
    } finally {
      setLoading(false)
    }
  }

  if (loading || dismissed || !status || status.isReady) {
    return null
  }

  return (
    <Card className="border-yellow-500 bg-yellow-50 dark:bg-yellow-950">
      <CardContent className="p-4">
        <div className="flex items-start gap-3">
          <AlertCircle className="h-5 w-5 text-yellow-600 flex-shrink-0 mt-0.5" />
          <div className="flex-1">
            <h3 className="font-semibold text-yellow-900 dark:text-yellow-100 mb-1">
              Database Setup Required
            </h3>
            <p className="text-sm text-yellow-800 dark:text-yellow-200 mb-3">
              Your Supabase database needs to be initialized. Please run the schema setup in your Supabase dashboard.
            </p>
            <div className="flex flex-wrap gap-2">
              <Button
                size="sm"
                variant="outline"
                className="border-yellow-600 text-yellow-700 hover:bg-yellow-100"
                onClick={() => window.open('https://supabase.com/dashboard', '_blank')}
              >
                <ExternalLink className="h-4 w-4 mr-2" />
                Open Supabase Dashboard
              </Button>
              <Button
                size="sm"
                variant="outline"
                className="border-yellow-600 text-yellow-700 hover:bg-yellow-100"
                onClick={() => setDismissed(true)}
              >
                Dismiss
              </Button>
            </div>
            {!status.connected && (
              <p className="text-xs text-yellow-700 dark:text-yellow-300 mt-2">
                ❌ Database connection failed - check your Supabase credentials
              </p>
            )}
            {status.connected && (
              <div className="text-xs text-yellow-700 dark:text-yellow-300 mt-2 space-y-1">
                <p className="font-medium">Missing tables:</p>
                {!status.tablesExist.profiles && <p>• profiles</p>}
                {!status.tablesExist.study_sessions && <p>• study_sessions</p>}
                {!status.tablesExist.achievements && <p>• achievements</p>}
                {!status.tablesExist.study_rooms && <p>• study_rooms</p>}
                {!status.tablesExist.tutor_profiles && <p>• tutor_profiles</p>}
              </div>
            )}
          </div>
        </div>
      </CardContent>
    </Card>
  )
}
