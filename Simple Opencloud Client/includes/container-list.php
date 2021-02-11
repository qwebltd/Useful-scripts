		<h1>Containers</h1>
		<h2>New Container</h2>
		<form action="<?php echo $_SERVER['REQUEST_URI']; ?>" method="post" enctype="multipart/form-data">
			<fieldset>
				<input type="hidden" name="create-container" value="1" />
				<label for="fldName">Name:</label>
				<input type="text" name="fldName" value="<?php echo (isset($_POST['fldName']) ? htmlentities($_POST['fldName'], ENT_QUOTES, 'UTF-8') : '' ); ?>" />
				<input type="submit" value="Create" />
			</fieldset>
		</form>
		<h2>Available containers</h2>
		<table style="width:100%">
			<thead>
				<tr>
					<th style="width:60%;text-align:left;">Name</th>
					<th style="width:40%;text-align:left;">Actions</th>
				</tr>
			</thead>
			<tbody>
<?php
	foreach($objects as $object) {
?>
				<tr>
					<td style="width:60%;text-align:left;">
						<a href="?password=<?php echo rawurlencode($_GET['password']); ?>&amp;container=<?php echo rawurlencode($object->getName()); ?>"><?php echo htmlentities($object->getName(), ENT_QUOTES, 'UTF-8'); ?></a>
					</td>
					<td style="width:40%;text-align:left;">
						<a class="js-confirm" href="?password=<?php echo rawurlencode($_GET['password']); ?>&amp;delete-container=<?php echo rawurlencode($object->getName()); ?>">Delete</a>
					</td>
				</tr>
<?php
	}
?>
			</tbody>
		</table>
