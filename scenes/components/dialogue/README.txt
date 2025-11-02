Dialogue:

All dialogue is stored and organized in the dialogue_scenes.xml file

Dialogue is structured by the following:
<dialogue_scenes>								<- This is the root node (Do not touch it)
	<prologue_boss>								<- This is a dialogue scene, this is a collection of segments
		<boss_greeting>							<- This is a dialogue segment, essentially a speech bubble
			<speaker>						<- This stores speaker information
				<name>[Name here]</name>			<- This stores the speaker's name, which will determine where we get the voice and face [Voice not yet implemented]
				<emotion>[Emotion here]</emotion>		<- This is the emotion the speaker has, which will determine which voice and face we use [Voice not yet implemented]
			</speaker>
			<message>						<- This is what the speaker says, use BBCode for rich text functionality
				[Text here]					<- Text goes here
			</message>
			<player_responses />					<- This will store possible player responses
				<first_response>[Display Text]</first_response>	<- <first_response> stores the segment the response will lead to (Don't just put "first_response")
				...						<- At least 2 to at most 4 responses. Only 1 response would be the next_segment, and 5 different options are just too many (I didn't program more than 4).
				<last_response>[Display Text]</last_response>	<- [Display Text] is what the response box will display as the option (doesn't have to be the actual dialogue that choice has, but try to remain in the spirit of the intended segment's dialogue)
			<next_segment>next_up</next_segment>			<- This stores the name of the segment that will follow the current one; this is likely mutually exclusive to player_responses, but could be used with a [Don't response] response
		</boss_greeting>
		<response_one />						<- Example of another segment
		<response_two />						<- Example of another segment
	</prologue_boss>
</dialogue_scenes>

You probably don't need to fully learn XML to add dialogue. Just follow the example structure.
You do, however, need to learn BBCode. It offers a lot of rich text functionality. Learn it!

DialogueManager will automatically add every dialogue scene to a dictionary when the game launches.
To display a specific scene, call DialogueManager.load_dialogue_scene(scene_name)
	scene_name is the name of the scene (so, please, don't make obtuse scene names)
This will automatically play the first segment; from there, DialogueHandler will deal with everything else during the scene.
It will currently emit the finish_cutscene signal when the dialogue is done (this may change)
	This provides a way to know when a dialogue is finished
