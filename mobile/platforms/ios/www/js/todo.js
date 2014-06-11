// Generated by CoffeeScript 1.7.1
(function() {
  window.Todo = (function() {
    function Todo(elems) {
      this.elems = elems != null ? elems : [];
      this.loadData();
      this.loadTemplates();
    }

    Todo.prototype.generateElems = function() {
      var html;
      if (this.templates.todo_list != null) {
        console.log("GENERATE ELEMENTs");
        html = swig.render(this.templates.todo_list, {
          locals: {
            tasks: this.tasks,
            color: "orange"
          }
        });
        $("main .all-content").html(html);
        return this.bindEvents();
      }
    };

    Todo.prototype.bindEvents = function() {
      var elem_names, _i, _results;
      elem_names = (function() {
        _results = [];
        for (_i = 1; _i <= 100; _i++){ _results.push(_i); }
        return _results;
      }).apply(this).map(function(n) {
        return "el-" + n;
      });
      console.log("BIND EVENTS");
      return $("main article .line").forEach(function(line, i) {
        var actions, elem, lineOffset, offs;
        elem = $(line).find(".content")[0];
        actions = [];
        offs = $(line).offset();
        lineOffset = offs.left;
        $(line).find(".mount").css("height", "" + offs.height + "px");
        $(line).find(".mount .actions .inline").forEach(function(cmd, i) {
          var offset, w;
          w = $(cmd).offset().width;
          offset = $(cmd).offset().left;
          return actions.push({
            off: offset,
            w: w,
            action: $(cmd).data("action")
          });
        });
        console.log("actions = " + (JSON.stringify(actions, null, 2)));
        $(elem).off();
        $(elem).data("name", elem_names[i]);
        return new window.T.ShiftBillet(elem, {
          name: elem_names[i],
          actions: actions,
          callback: function() {
            var a, _j, _len, _ref, _results1;
            if (this.lastX > 0) {
              _results1 = [];
              for (_j = 0, _len = actions.length; _j < _len; _j++) {
                a = actions[_j];
                if ((a.off + a.w <= (_ref = this.lastX) && _ref <= a.off + a.w * 1.3)) {
                  app.notify(null, "action = " + a.action);
                  break;
                } else {
                  _results1.push(void 0);
                }
              }
              return _results1;
            } else {
              return app.notify(null, "влево");
            }
          }
        });
      });
    };

    Todo.prototype.loadData = function() {
      this.folders = {};
      return this.tasks = ["foo", "bar", "fuzz", "Lorem ipsum, Dolor sit amet, consectetuer adipiscing loreum ipsum edipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.Loreum ipsum edipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat."];
    };

    Todo.prototype.loadTemplates = function() {
      this.templates = {};
      return $("script[type='text/tmpl']").each((function(_this) {
        return function(id, el) {
          var name;
          name = $(el).attr("data-name");
          if (0 === name.indexOf("todo_")) {
            _this.templates[name] = el.text;
            return $(el).remove();
          }
        };
      })(this));
    };

    return Todo;

  })();

}).call(this);
