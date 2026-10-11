package com.grievance.scheduler;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@WebListener
public class EscalationListener implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent event) {

        scheduler = Executors.newSingleThreadScheduledExecutor();

        EscalationScheduler escalationScheduler =
                new EscalationScheduler();

        scheduler.scheduleAtFixedRate(
                escalationScheduler::processEscalations,
                0,
                1,
                TimeUnit.HOURS
        );
    }

    @Override
    public void contextDestroyed(ServletContextEvent event) {

        if (scheduler != null) {
            scheduler.shutdown();
        }
    }
}