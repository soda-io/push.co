
{% raw %}

<script type="text/tmpl" data-name="todo_list">
  <article class='{{ color }}'>
    {% for t in tasks %}
    <div class='line'>
      <div class='mount'>
        <div class='actions'>
          <div class='inline nice-lime-90-neon' data-action="done">
            <div class='fa fa-check'></div>
            <div class='tip-text'>выполнить</div>
          </div>
          <div class='inline nice-steel-90-neon' data-action="up">
            <span class='fa fa-pencil'></span>
            <br>
            <span class='tip-text'>изменить</span>
          </div>
          <div class='inline nice-orange-90-neon' data-action="remember">
            <span class='fa fa-bell'></span>
            <br>
            <span class='tip-text'>напомнить</span>
          </div>

          <div class='inline nice-scarlet-90-neon' data-action="rm">
            <span class='fa fa-ban'></span>
            <br>
            <span class='tip-text'>удалить</span>
          </div>
        </div>
      </div>
      <div class='content'>
        <div class='text'>{{ t }}</div>
      </div>
    </div>
    {% endfor %}
  </article>
  {% if (tasks.length == 0) %}
  <div class="input-task nice-white-90-neon">
    добавить новую задачу
  </div>
  {% endif %}
</script>

{% endraw %}



<main class="nice-white-50">
  <div class="all-content">

    {#
    <header>
      <span class="fa fa-plus-circle nice-lime-90 call-menu pointer"></span>
      <span class="fa fa-stack-exchange call-menu pointer"></span>
    </header>
    #}

  </div>
</main>
