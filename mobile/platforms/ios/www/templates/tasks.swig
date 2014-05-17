
{% raw %}

<script type="text/tmpl" data-name="todo_list">
  <article class='magenta-col'>
  {% for t in tasks %}
        <div class='line'>
	  <div class='mount'>
	    <div class='actions'>
	      <div class='inline nice-lime-90-neon'>
		<span class='fa fa-check'></span>
		<br>
		<span class='tip-text'>выполнить</span>
	      </div>
	      <div class='inline nice-steel-90-neon inactive'>
		<span class='fa fa-pencil'></span>
		<br>
		<span class='tip-text'>изменить</span>
	      </div>
	      <div class='inline nice-orange-90-neon inactive'>
		<span class='fa fa-bell'></span>
		<br>
		<span class='tip-text'>напомнить</span>
	      </div>
	      <div class='inline nice-magenta-90-neon inactive'>
		<span class='fa fa-calendar'></span>
		<br>
		<span class='tip-text'>планировать</span>
	      </div>

	      <div class='inline nice-scarlet-90-neon'>
		<span class='fa fa-ban'></span>
		<br>
		<span class='tip-text'>удалить</span>
	      </div>
	    </div>
	  </div>
    <div class='content'>
      <div class='text'>{{ t }}</div>
    </div>
  {% endfor %}
  </article>

</script>

{% endraw %}



<main class="nice-white-50">
    <div class="all-content">

      <header>
        <span class="fa fa-plus-circle nice-lime-90 call-menu pointer"></span>
        <span class="fa fa-stack-exchange call-menu pointer"></span>
      </header>
      <article class="magenta-col">

      </article>

    </div>
</main>
