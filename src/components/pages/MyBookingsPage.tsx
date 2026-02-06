import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import {
  Calendar,
  Clock,
  Hash,
  CheckCircle,
  XCircle,
  AlertTriangle,
  Loader2,
  ArrowLeft,
  CalendarPlus,
} from 'lucide-react';
import { useAuth } from '../../contexts/AuthContext';
import { sessionBookingService } from '../../services/sessionBookingService';
import type { SessionBooking, BookingStatus } from '../../types/session';

const statusConfig: Record<BookingStatus, { label: string; color: string; icon: React.ReactNode }> = {
  confirmed: {
    label: 'Confirmed',
    color: 'bg-emerald-500/10 text-emerald-400 border-emerald-500/30',
    icon: <CheckCircle className="w-3.5 h-3.5" />,
  },
  completed: {
    label: 'Completed',
    color: 'bg-blue-500/10 text-blue-400 border-blue-500/30',
    icon: <CheckCircle className="w-3.5 h-3.5" />,
  },
  cancelled: {
    label: 'Cancelled',
    color: 'bg-red-500/10 text-red-400 border-red-500/30',
    icon: <XCircle className="w-3.5 h-3.5" />,
  },
  no_show: {
    label: 'No Show',
    color: 'bg-amber-500/10 text-amber-400 border-amber-500/30',
    icon: <AlertTriangle className="w-3.5 h-3.5" />,
  },
};

export const MyBookingsPage: React.FC = () => {
  const navigate = useNavigate();
  const { user, isAuthenticated, isLoading: authLoading } = useAuth();
  const [bookings, setBookings] = useState<SessionBooking[]>([]);
  const [loading, setLoading] = useState(true);
  const [cancellingId, setCancellingId] = useState<string | null>(null);
  const [showCancelConfirm, setShowCancelConfirm] = useState<string | null>(null);

  useEffect(() => {
    if (!authLoading && !isAuthenticated) {
      navigate('/session');
      return;
    }
    if (user) {
      loadBookings();
    }
  }, [user, isAuthenticated, authLoading]);

  const loadBookings = async () => {
    if (!user) return;
    setLoading(true);
    const data = await sessionBookingService.getUserBookings(user.id);
    setBookings(data);
    setLoading(false);
  };

  const handleCancel = async (bookingId: string) => {
    setCancellingId(bookingId);
    const result = await sessionBookingService.cancelBooking(bookingId);
    if (result.success) {
      await loadBookings();
    }
    setCancellingId(null);
    setShowCancelConfirm(null);
  };

  const today = new Date().toISOString().split('T')[0];
  const upcoming = bookings.filter(
    (b) => b.status === 'confirmed' && b.booking_date >= today
  );
  const past = bookings.filter(
    (b) => b.status !== 'confirmed' || b.booking_date < today
  );

  const formatDate = (dateStr: string) => {
    const d = new Date(dateStr + 'T00:00:00');
    return d.toLocaleDateString('en-IN', {
      weekday: 'short',
      day: 'numeric',
      month: 'short',
      year: 'numeric',
    });
  };

  const renderBookingCard = (booking: SessionBooking) => {
    const status = statusConfig[booking.status as BookingStatus] || statusConfig.confirmed;
    const slotLabel = sessionBookingService.getSlotLabel(booking.time_slot);
    const isUpcoming = booking.status === 'confirmed' && booking.booking_date >= today;

    return (
      <motion.div
        key={booking.id}
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-slate-800/40 border border-slate-700/50 rounded-xl p-5 hover:border-slate-600/50 transition-colors"
      >
        <div className="flex items-start justify-between mb-3">
          <h3 className="text-white font-semibold text-sm line-clamp-1">
            {booking.session_services?.title || 'Resume Session'}
          </h3>
          <span
            className={`inline-flex items-center gap-1 text-xs font-medium px-2.5 py-1 rounded-full border ${status.color}`}
          >
            {status.icon}
            {status.label}
          </span>
        </div>

        <div className="space-y-2 text-sm">
          <div className="flex items-center gap-2 text-slate-300">
            <Calendar className="w-4 h-4 text-slate-500" />
            {formatDate(booking.booking_date)}
          </div>
          <div className="flex items-center gap-2 text-slate-300">
            <Clock className="w-4 h-4 text-slate-500" />
            {slotLabel}
          </div>
          <div className="flex items-center gap-2 text-slate-400">
            <Hash className="w-4 h-4 text-slate-500" />
            <span className="font-mono text-xs">{booking.booking_code}</span>
          </div>
        </div>

        {isUpcoming && (
          <div className="mt-4 pt-3 border-t border-slate-700/50">
            {showCancelConfirm === booking.id ? (
              <div className="space-y-2">
                <p className="text-amber-400 text-xs">Are you sure you want to cancel?</p>
                <div className="flex gap-2">
                  <button
                    onClick={() => handleCancel(booking.id)}
                    disabled={cancellingId === booking.id}
                    className="flex-1 px-3 py-2 rounded-lg bg-red-500/20 text-red-400 text-xs font-medium hover:bg-red-500/30 disabled:opacity-50 transition-colors"
                  >
                    {cancellingId === booking.id ? 'Cancelling...' : 'Yes, Cancel'}
                  </button>
                  <button
                    onClick={() => setShowCancelConfirm(null)}
                    className="flex-1 px-3 py-2 rounded-lg border border-slate-700 text-slate-300 text-xs font-medium hover:bg-slate-800/60 transition-colors"
                  >
                    Keep Booking
                  </button>
                </div>
              </div>
            ) : (
              <button
                onClick={() => setShowCancelConfirm(booking.id)}
                className="text-xs text-red-400/70 hover:text-red-400 transition-colors"
              >
                Cancel Booking
              </button>
            )}
          </div>
        )}
      </motion.div>
    );
  };

  if (authLoading || loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loader2 className="w-8 h-8 text-emerald-400 animate-spin" />
      </div>
    );
  }

  return (
    <div className="min-h-screen pb-20 md:pl-16">
      <div className="max-w-3xl mx-auto px-4 sm:px-6 pt-8 sm:pt-12">
        <button
          onClick={() => navigate(-1)}
          className="flex items-center gap-1.5 text-slate-400 hover:text-white text-sm mb-6 transition-colors"
        >
          <ArrowLeft className="w-4 h-4" />
          Back
        </button>

        <div className="flex items-center justify-between mb-8">
          <h1 className="text-2xl sm:text-3xl font-bold text-white">My Bookings</h1>
          <button
            onClick={() => navigate('/session')}
            className="flex items-center gap-1.5 px-4 py-2 rounded-lg bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-sm font-medium hover:bg-emerald-500/20 transition-colors"
          >
            <CalendarPlus className="w-4 h-4" />
            Book New
          </button>
        </div>

        {bookings.length === 0 ? (
          <div className="text-center py-16">
            <Calendar className="w-12 h-12 text-slate-600 mx-auto mb-4" />
            <h3 className="text-white font-semibold text-lg mb-2">No bookings yet</h3>
            <p className="text-slate-400 text-sm mb-6">
              Book a 1-on-1 resume session with our experts
            </p>
            <button
              onClick={() => navigate('/session')}
              className="px-6 py-3 rounded-xl bg-gradient-to-r from-emerald-500 to-teal-500 text-white font-semibold hover:shadow-lg hover:shadow-emerald-500/25 transition-all"
            >
              Book a Session
            </button>
          </div>
        ) : (
          <>
            {upcoming.length > 0 && (
              <section className="mb-10">
                <h2 className="text-lg font-semibold text-white mb-4 flex items-center gap-2">
                  <span className="w-2 h-2 rounded-full bg-emerald-400" />
                  Upcoming Sessions
                </h2>
                <div className="grid gap-4 sm:grid-cols-2">
                  {upcoming.map(renderBookingCard)}
                </div>
              </section>
            )}

            {past.length > 0 && (
              <section>
                <h2 className="text-lg font-semibold text-white mb-4 flex items-center gap-2">
                  <span className="w-2 h-2 rounded-full bg-slate-500" />
                  Past Sessions
                </h2>
                <div className="grid gap-4 sm:grid-cols-2">
                  {past.map(renderBookingCard)}
                </div>
              </section>
            )}
          </>
        )}
      </div>
    </div>
  );
};
