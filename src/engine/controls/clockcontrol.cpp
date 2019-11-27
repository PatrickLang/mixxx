#include "engine/controls/clockcontrol.h"

#include "control/controlobject.h"
#include "preferences/usersettings.h"
#include "engine/controls/enginecontrol.h"
#include "control/controlproxy.h"

ClockControl::ClockControl(QString group, UserSettingsPointer pConfig)
        : EngineControl(group, pConfig) {
    m_pCOBeatActive = new ControlObject(ConfigKey(group, "beat_active"));
    m_pCOBeatActive->set(0.0);
    m_pCOSampleRate = new ControlProxy("[Master]","samplerate");
    m_pCOPpqnActive->set(0.0);
    m_pCOPpqnActive = new ControlObject(ConfigKey(group, "ppqn_active"));
}

ClockControl::~ClockControl() {
    delete m_pCOBeatActive;
    delete m_pCOSampleRate;
}

// called from an engine worker thread
void ClockControl::trackLoaded(TrackPointer pNewTrack) {
    // Clear on-beat control
    m_pCOBeatActive->set(0.0);

    // Clear ppqn control
    m_pCOPpqnActive->set(0.0);

    // Disconnect any previously loaded track/beats
    if (m_pTrack) {
        disconnect(m_pTrack.get(), &Track::beatsUpdated,
                   this, &ClockControl::slotBeatsUpdated);
    }
    if (pNewTrack) {
        m_pTrack = pNewTrack;
        m_pBeats = m_pTrack->getBeats();
        connect(m_pTrack.get(), &Track::beatsUpdated,
                this, &ClockControl::slotBeatsUpdated);
    } else {
        m_pBeats.clear();
        m_pTrack.reset();
    }

}

void ClockControl::slotBeatsUpdated() {
    TrackPointer pTrack = m_pTrack;
    if(pTrack) {
        m_pBeats = pTrack->getBeats();
    }
}

void ClockControl::process(const double dRate,
                           const double currentSample,
                           const int iBuffersize) {
    Q_UNUSED(iBuffersize);
    double samplerate = m_pCOSampleRate->get();

    // TODO(XXX) should this be customizable, or latency dependent?
    const double blinkSeconds = 0.100;

    // Multiply by two to get samples from frames. Interval is scaled linearly
    // by the rate.
    const double blinkIntervalSamples = 2.0 * samplerate * (1.0 * dRate) * blinkSeconds;

    // Max BPM / 60 seconds per minute / 24 ppqn
    // Max 240 bpm because I had to pick a number
    const double ppqnSeconds = 240.0 / 60.0 / 24.0;
    const double ppqnIntervalSamples = samplerate * (1.0 * dRate) * ppqnSeconds;

    BeatsPointer pBeats = m_pBeats;
    if (pBeats) {
        double closestBeat = pBeats->findClosestBeat(currentSample);
        double distanceToClosestBeat = fabs(currentSample - closestBeat);
        double distanceToClosestPpqn = distanceToClosestBeat / 24;
        m_pCOBeatActive->set(distanceToClosestBeat < blinkIntervalSamples / 2.0);
        m_pCOPpqnActive->set(distanceToClosestPpqn < ppqnSeconds / 2.0)
    }
}
