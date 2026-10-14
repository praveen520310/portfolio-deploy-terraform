
/* =========================================================
   PAUL PRAVEEN KUMAR ATHMURI | DEVSECOPS PORTFOLIO
   Complete JavaScript
   ========================================================= */

document.addEventListener("DOMContentLoaded", function () {
    "use strict";

    /* ---------- Automatically Update Footer Year ---------- */
    const yearElement = document.getElementById("year");

    if (yearElement) {
        yearElement.textContent = new Date().getFullYear();
    }

    /* ---------- Mobile Navigation ---------- */
    const menuToggle = document.querySelector(".menu-toggle");
    const navLinks = document.querySelector(".nav-links");
    const navItems = document.querySelectorAll(".nav-links a");

    function closeMenu() {
        if (!menuToggle || !navLinks) {
            return;
        }

        navLinks.classList.remove("open");
        menuToggle.setAttribute("aria-expanded", "false");
        menuToggle.setAttribute("aria-label", "Open navigation");
        menuToggle.textContent = "☰";
    }

    function openMenu() {
        if (!menuToggle || !navLinks) {
            return;
        }

        navLinks.classList.add("open");
        menuToggle.setAttribute("aria-expanded", "true");
        menuToggle.setAttribute("aria-label", "Close navigation");
        menuToggle.textContent = "✕";
    }

    if (menuToggle && navLinks) {
        menuToggle.addEventListener("click", function () {
            const isOpen = navLinks.classList.contains("open");

            if (isOpen) {
                closeMenu();
            } else {
                openMenu();
            }
        });

        navItems.forEach(function (link) {
            link.addEventListener("click", function () {
                closeMenu();
            });
        });

        document.addEventListener("click", function (event) {
            const clickedInsideNavigation =
                menuToggle.contains(event.target) ||
                navLinks.contains(event.target);

            if (!clickedInsideNavigation) {
                closeMenu();
            }
        });

        document.addEventListener("keydown", function (event) {
            if (event.key === "Escape") {
                closeMenu();
            }
        });

        window.addEventListener("resize", function () {
            if (window.innerWidth > 760) {
                closeMenu();
            }
        });
    }

    /* ---------- Smooth Navigation ---------- */
    const internalLinks = document.querySelectorAll('a[href^="#"]');

    internalLinks.forEach(function (link) {
        link.addEventListener("click", function (event) {
            const targetId = link.getAttribute("href");

            if (!targetId || targetId === "#") {
                return;
            }

            const targetElement = document.querySelector(targetId);

            if (!targetElement) {
                return;
            }

            event.preventDefault();

            targetElement.scrollIntoView({
                behavior: window.matchMedia(
                    "(prefers-reduced-motion: reduce)"
                ).matches
                    ? "auto"
                    : "smooth",
                block: "start"
            });

            /*
             * Update the browser URL without reloading the page.
             * This keeps links such as #projects working correctly.
             */
            if (window.location.hash !== targetId) {
                history.pushState(null, "", targetId);
            }
        });
    });

    /* ---------- Active Navigation Highlight ---------- */
    const pageSections = document.querySelectorAll("main section[id]");

    function setActiveNavigation() {
        let currentSection = "home";
        const scrollPosition = window.scrollY + 150;

        pageSections.forEach(function (section) {
            if (section.offsetTop <= scrollPosition) {
                currentSection = section.id;
            }
        });

        navItems.forEach(function (link) {
            const linkTarget = link.getAttribute("href");

            if (linkTarget === "#" + currentSection) {
                link.classList.add("active");
            } else {
                link.classList.remove("active");
            }
        });
    }

    window.addEventListener("scroll", setActiveNavigation, {
        passive: true
    });

    window.addEventListener("resize", setActiveNavigation);

    setActiveNavigation();

    /* ---------- Reveal Elements on Scroll ---------- */
    const revealSelectors = [
        ".section-title",
        ".about-card",
        ".skill-category",
        ".education-card",
        ".project-card",
        ".contact-card"
    ];

    const revealElements = document.querySelectorAll(
        revealSelectors.join(", ")
    );

    const prefersReducedMotion = window.matchMedia(
        "(prefers-reduced-motion: reduce)"
    ).matches;

    if ("IntersectionObserver" in window && !prefersReducedMotion) {
        const revealObserver = new IntersectionObserver(
            function (entries, observer) {
                entries.forEach(function (entry) {
                    if (entry.isIntersecting) {
                        entry.target.classList.add("visible");
                        observer.unobserve(entry.target);
                    }
                });
            },
            {
                threshold: 0.08,
                rootMargin: "0px 0px -20px 0px"
            }
        );

        revealElements.forEach(function (element) {
            element.classList.add("reveal");
            revealObserver.observe(element);
        });
    } else {
        revealElements.forEach(function (element) {
            element.classList.add("visible");
        });
    }

    /* ---------- Project Link Safety ---------- */
    const externalLinks = document.querySelectorAll(
        '.project-btn[target="_blank"], .contact-card a[target="_blank"]'
    );

    externalLinks.forEach(function (link) {
        link.setAttribute("rel", "noopener noreferrer");
    });

    /* ---------- Prevent Empty Placeholder Links ---------- */
    document.querySelectorAll('a[href="#"]').forEach(function (link) {
        link.addEventListener("click", function (event) {
            event.preventDefault();
        });
    });

    /* ---------- Console Confirmation ---------- */
    console.info(
        "DevSecOps portfolio loaded successfully."
    );
});
