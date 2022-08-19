$( document ).ready(function() {
    // https://jsfiddle.net/wizajay/rro5pna3/305/
    var Clock = {
        totalSeconds: 0,
        start: function () {
            if (!this.interval) {
              var self = this;
              function pad(val) { return val > 9 ? val : "0" + val; }
              this.interval = setInterval(function () {
                self.totalSeconds += 1;
      
      
                $("#min").text(pad(Math.floor(self.totalSeconds / 60 % 60)));
                $("#sec").text(pad(parseInt(self.totalSeconds % 60)));
              }, 1000);
            }
        },
        
        reset: function () {
            Clock.totalSeconds = null; 
          clearInterval(this.interval);
          $("#min").text("00");
          $("#sec").text("00");
          delete this.interval;
        },
        pause: function () {
          clearInterval(this.interval);
          delete this.interval;
        },
      
        resume: function () {
          this.start();
        },
        
        restart: function () {
             this.reset();
           Clock.start();
        }
      };
      
      
      $('#instructor-start').click(function () { Clock.start(); });
      $('#pauseButton').click(function () { Clock.pause(); });
      $('#resumeButton').click(function () { Clock.resume(); });
      $('#instructor-stop').click(function () { Clock.reset(); });
      $('#restartButton').click(function () { Clock.restart(); });
       

});

