async function initVisitorCounter() {
    const visitorCounterContainerId = "visitor-counter-container";
    const visitorCounterContainer = document.getElementById(visitorCounterContainerId);
    // Exit early if container is not found
    if (!visitorCounterContainer) {
        console.error(`HTML element with id '${visitorCounterContainerId}' was not found`);
        return;
    }
    
    const apiEndpoint = ""
    const visitorCounterElement = document.createElement("p");
    const visitorCounterTextPrefix = "Site Visitor Counter:"
    visitorCounterContainer.appendChild(visitorCounterElement);
    
    const data = await getData(apiEndpoint)
    visitorCounterElement.textContent = data?.count ? 
        `${visitorCounterTextPrefix} ${data.count}` :
        `${visitorCounterTextPrefix} Error has occured`
}

async function getData(url){
    if (typeof url != 'string') return

    try {
        const response = await fetch(url);
        if (!response.ok) {
            throw new Error(`API responded with status code: ${response.status}`);
        }

        const data = await response.json()
        return data
    } catch (error) {
        console.error(`Failed to fetch visitor count: ${error}`)
        return
    }
}

if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initVisitorCounter())
} else {
    initVisitorCounter()
}