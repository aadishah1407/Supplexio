package com.axaltacoating.filter;

import java.io.IOException;
import javax.servlet.*;
import java.util.logging.Logger;

//@WebFilter("/*")  // DISABLED - No need for startup checks
public class DatabaseReadinessFilter implements Filter {
    private static final Logger LOGGER = Logger.getLogger(DatabaseReadinessFilter.class.getName());

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        LOGGER.info("DatabaseReadinessFilter is disabled");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        // Filter disabled - pass through immediately
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        LOGGER.info("DatabaseReadinessFilter destroyed");
    }
}