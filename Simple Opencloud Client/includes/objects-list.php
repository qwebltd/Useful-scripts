		<h1>Objects</h1>
		<h2>New Folder</h2>
		<form action="<?php echo $_SERVER['REQUEST_URI']; ?>" method="post" enctype="multipart/form-data">
			<fieldset>
				<input type="hidden" name="create-folder" value="1" />
				<label for="fldName">Name:</label>
				<input type="text" name="fldName" value="<?php echo (isset($_POST['fldName']) ? htmlentities($_POST['fldName'], ENT_QUOTES, 'UTF-8') : '' ); ?>" />
				<input type="submit" value="Create" />
			</fieldset>
		</form>
		<h2>New File</h2>
		<form action="<?php echo $_SERVER['REQUEST_URI']; ?>" method="post" enctype="multipart/form-data">
			<fieldset>
				<input type="hidden" name="create-file" value="1" />
				<label for="fldFile">File:</label>
				<input type="file" name="fldFile" />
				<input type="submit" value="Upload" />
			</fieldset>
		</form>
		<h2>Available objects</h2>
		<table style="width:100%">
			<thead>
				<tr>
					<th style="width:60%;text-align:left;">Name</th>
					<th style="width:40%;text-align:left;">Actions</th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td colspan="2" style="width:100%;text-align:left;">
<?php
	if(isset($_GET['parent'])) {
?>
						<a href="?password=<?php echo rawurlencode($_GET['password']); ?>&amp;container=<?php echo rawurlencode($_GET['container']); ?>&amp;level=<?php echo rawurlencode($_GET['parent']); ?>">..</a>
<?php
	} else {
?>
						<a href="?password=<?php echo rawurlencode($_GET['password']); ?>">..</a>
<?php
	}
?>
					</td>
				</tr>
<?php
	foreach($objects as $object) {
?>
				<tr>
					<td style="width:60%;text-align:left;">
<?php
		if($object->getContentType() == 'application/directory') {
?>
						<a href="?password=<?php echo rawurlencode($_GET['password']); ?>&amp;container=<?php echo rawurlencode($_GET['container']); ?>&amp;level=<?php echo rawurlencode($object->getName().'/'); ?>&amp;parent=<?php echo (isset($_GET['level']) ? rawurlencode($_GET['level']) : ''); ?>"><?php echo htmlentities($object->getName(), ENT_QUOTES, 'UTF-8'); ?></a>
<?php
		} else {
?>
						<?php echo htmlentities($object->getName(), ENT_QUOTES, 'UTF-8'); ?>
<?php
		}
?>
					</td>
					<td style="width:40%;text-align:left;">
<?php
		if($object->getContentType() == 'application/directory') {
?>
						<a class="js-confirm" target="_blank" href="?password=<?php echo rawurlencode($_GET['password']); ?>&amp;container=<?php echo rawurlencode($_GET['container']); ?>&amp;download-object=<?php echo rawurlencode($object->getName()); ?>">Download</a>
<?php
		} else {
?>
						<a target="_blank" href="?password=<?php echo rawurlencode($_GET['password']); ?>&amp;container=<?php echo rawurlencode($_GET['container']); ?>&amp;download-object=<?php echo rawurlencode($object->getName()); ?>">Download</a>
<?php
		}
?>
						<a class="js-confirm" href="?password=<?php echo rawurlencode($_GET['password']); ?>&amp;container=<?php echo rawurlencode($_GET['container']); ?>&amp;parent=<?php echo (isset($_GET['level']) ? rawurlencode($_GET['level']) : ''); ?>&amp;delete-object=<?php echo rawurlencode($object->getName()); ?>">Delete</a>
					</td>
				</tr>
<?php
	}
?>
			</tbody>
		</table>
