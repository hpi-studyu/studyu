{{flutter_js}}
{{flutter_build_config}}

// Create the loading indicator element
var loadingDiv = document.createElement('div');
loadingDiv.id = 'loading';
loadingDiv.innerHTML = `
  <style>
    body {
      inset: 0;
      overflow: hidden;
      margin: 0;
      padding: 0;
      position: fixed;
    }

    #loading {
      align-items: center;
      display: flex;
      height: 100%;
      justify-content: center;
      width: 100%;
    }

    #loading img {
      animation: 1s ease-in-out 0s infinite alternate breathe;
      # opacity: .66;
      transition: opacity .4s;
    }

    #loading.main_done img {
      opacity: 1;
    }

    #loading.init_done img {
      animation: .33s ease-in-out 0s 1 forwards zooooom;
      opacity: .05;
    }

    @keyframes breathe {
      from {
        transform: scale(1);
      }

      to {
        transform: scale(0.9);
      }
    }

    @keyframes zooooom {
      from {
        transform: scale(1);
      }

      to {
        transform: scale(0.01);
      }
    }
  </style>
  <img src="icons/Icon-192.png" alt="Loading indicator..." />
`;

// Append the loading indicator to the document body
document.body.appendChild(loadingDiv);
// Loading entrypoint
_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    // Initializing engine
    loadingDiv.classList.add('main_done');
    const appRunner = await engineInitializer.initializeEngine();

    // Running app
    loadingDiv.classList.add('init_done');
    await appRunner.runApp();
  }
});