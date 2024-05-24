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
      background-color: #3088cf;
      display: flex;
      height: 100%;
      justify-content: center;
      width: 100%;
    }

    #loading-box {
      background-color: white;
      border-radius: 10px;
      padding: 20px;
    }

    #loading img {
      animation: 1s ease-in-out 0s infinite alternate breathe;
      opacity: 1.0;
      transition: opacity .4s;
    }

    #loading.init_done img {
      animation: .33s ease-in-out 0s 1 forwards zooooom;
      opacity: .05;
    }

    @keyframes breathe {
      from {
        transform: scale(0.9);
      }

      to {
        transform: scale(0.8);
      }
    }

    @keyframes zooooom {
      from {
        transform: scale(0.9);
      }

      to {
        transform: scale(0.01);
      }
    }
  </style>
  <div id="loading-box">
    <img src="icons/Icon-192.png" alt="Loading indicator..." />
  </div>
`;

// Append the loading indicator to the document body
document.body.appendChild(loadingDiv);

// Loading entrypoint
_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();

    loadingDiv.classList.add('init_done');
    // Hide the loading indicator after the animation is done
    loadingDiv.addEventListener('animationend', function() {
        document.getElementById('loading').style.visibility = 'hidden';
    });

    await appRunner.runApp();
  }
});
